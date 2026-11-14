set shell := ["bash", "-euo", "pipefail", "-c"]

profile := `chezmoi data --format json 2>/dev/null | jq -r .profile 2>/dev/null || echo unset`

default:
    @just --list

# First run on a machine: just bootstrap work|home [--dry-run]
bootstrap *args:
    ./bootstrap.sh {{args}}

# Show pending changes (repo -> home)
diff:
    chezmoi diff

# Apply repo to home, then packages
apply:
    chezmoi apply -v
    just pkgs-install

# Copy edits made in live files back into the repo
save:
    chezmoi re-add

# Install shared + profile packages
pkgs-install:
    brew bundle --file brew/Brewfile.shared
    brew bundle --file brew/Brewfile.{{profile}}
    mise install

# Missing and unmanaged packages
pkgs:
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{justfile_directory()}}
    want() { cat brew/Brewfile.shared brew/Brewfile.{{profile}} | sed -n "s/^$1 \"\(.*\)\".*/\1/p" | sed 's#.*/##' | sort -u; }
    known() { cat brew/Brewfile.* | sed -n "s/^$1 \"\(.*\)\".*/\1/p" | sed 's#.*/##'; }
    bad=0
    echo "profile: {{profile}}"
    echo "-- missing (in manifest, not installed)"
    m=$(comm -23 <(want brew) <(brew list --formula | sort -u); comm -23 <(want cask) <(brew list --cask | sort -u))
    [ -z "$m" ] || { echo "$m"; bad=1; }
    echo "-- unmanaged (installed, in no manifest and not in brew/untracked.txt)"
    u=$(comm -23 <(brew leaves | sort -u) <( (known brew; grep -v '^#' brew/untracked.txt) | sort -u); comm -23 <(brew list --cask | sort -u) <( (known cask; grep -v '^#' brew/untracked.txt) | sort -u))
    [ -z "$u" ] || echo "$u"
    exit $bad

# Machine and setup health
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    fail=0; ok() { echo "ok    $*"; }; no() { echo "FAIL  $*"; fail=1; }
    for t in brew chezmoi just mise git nvim jq gitleaks starship zoxide fzf; do command -v $t >/dev/null && ok "$t" || no "$t missing"; done
    p=$(chezmoi data --format json | jq -r .profile); [[ $p == work || $p == home ]] && ok "profile=$p" || no "profile not set"
    [ "$(chezmoi source-path)" = "$HOME/dotfiles/home" ] && ok "source $HOME/dotfiles/home" || no "chezmoi source-path is $(chezmoi source-path)"
    d=$(find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print; find ~/.config ~/.claude ~/.codex -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null | grep -v -e herdr.sock -e '/debug/latest')
    [ -z "$d" ] && ok "no dangling symlinks" || { no "dangling symlinks:"; echo "$d"; }
    chezmoi verify >/dev/null 2>&1 && ok "home matches repo" || no "home differs from repo (just diff)"
    git config user.email >/dev/null && ok "git identity set" || no "git user.email missing (~/.gitconfig.local)"
    ssh -G github.com >/dev/null 2>&1 && ok "ssh config parses" || no "ssh config broken"
    for k in $(ssh -G github.com 2>/dev/null | awk '/^identityfile /{print $2}'); do k=${k/#\~/$HOME}; [ -f "$k" ] && ok "ssh key $k" || no "ssh key $k missing"; done
    [ -f ~/.zshrc.local ] && ok "~/.zshrc.local present" || echo "warn  ~/.zshrc.local missing (secrets live there)"
    s=$( { /usr/bin/time -p env -i HOME=$HOME TERM=xterm zsh -l -i -c exit; } 2>&1 | awk '/real/{print $2}'); ok "zsh startup ${s}s"
    dup=$(env -i HOME=$HOME TERM=xterm zsh -l -i -c "print -l \$path" 2>/dev/null | sort | uniq -d); [ -z "$dup" ] && ok "PATH has no duplicates" || { no "PATH duplicates:"; echo "$dup"; }
    mise doctor >/dev/null 2>&1 && ok "mise doctor" || echo "warn  mise doctor reported issues"
    exit $fail

# Full check: render both profiles, syntax, secrets, ignore rules, manifests
verify:
    #!/usr/bin/env bash
    set -uo pipefail
    cd {{justfile_directory()}}
    fail=0; ok() { echo "ok    $*"; }; no() { echo "FAIL  $*"; fail=1; }
    t=$(mktemp -d); trap 'rm -rf $t' EXIT
    for p in work home; do
      printf 'sourceDir = "%s"\n[data]\n  profile = "%s"\n' "$PWD" $p > $t/$p.toml
      mkdir -p $t/$p; chezmoi -c $t/$p.toml --persistent-state $t/$p.db -D $t/$p apply --exclude=scripts,externals >/dev/null 2>$t/err && ok "render $p" || { no "render $p"; cat $t/err; }
      zsh -n $t/$p/.zshrc && ok "zsh syntax $p" || no "zsh syntax $p"
      ssh -G -F $t/$p/.ssh/config github.com >/dev/null 2>&1 && ok "ssh config $p" || no "ssh config $p"
    done
    grep -q jenv $t/home/.zshrc && no "java leaked into home" || ok "home has no java/jenv"
    grep -q lendbeta $t/home/.ssh/config && no "work host leaked into home" || ok "home has no work ssh host"
    grep -q jenv $t/work/.zshrc && ok "work has java" || no "work lost java"
    while read -r f; do case $f in
      *.json) jq empty $f 2>/dev/null || no "json $f";; *.toml) python3 -c 'import sys,tomllib;tomllib.load(open(sys.argv[1],"rb"))' $f 2>/dev/null || no "toml $f";; esac
    done < <(find $t/work -type f \( -name '*.json' -o -name '*.toml' \) ! -path '*/zed/*')
    ok "json/toml syntax"
    g=$(command -v ghostty || echo /Applications/Ghostty.app/Contents/MacOS/ghostty)
    $g +validate-config --config-file=$t/work/.config/ghostty/config >/dev/null 2>&1 && ok "ghostty config" || no "ghostty config"
    zellij --config $t/work/.config/zellij/config.kdl setup --check >/dev/null 2>&1 && ok "zellij config" || no "zellij config"
    bash -n bootstrap.sh && ok "bootstrap syntax" || no "bootstrap syntax"
    shellcheck bootstrap.sh && ok "shellcheck" || no "shellcheck"
    ign=$(git ls-files -oi --exclude-standard . ; comm -13 <(git ls-files | sort) <(find . -path ./.git -prune -o -type f -print | sed 's#^\./##' | sort))
    [ -z "$ign" ] && ok "no untracked or ignored files in repo" || { no "untracked/ignored files:"; echo "$ign"; }
    gitleaks dir . --no-banner --redact >/dev/null 2>&1 && ok "gitleaks working tree" || no "gitleaks working tree"
    gitleaks git . --no-banner --redact >/dev/null 2>&1 && ok "gitleaks history" || no "gitleaks history"
    for p in shared work home; do brew bundle list --file brew/Brewfile.$p >/dev/null 2>&1 && ok "Brewfile.$p parses" || no "Brewfile.$p"; done
    mise ls --current >/dev/null 2>&1 && ok "mise config" || no "mise config"
    exit $fail
