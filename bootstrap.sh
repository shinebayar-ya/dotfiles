#!/usr/bin/env bash
set -euo pipefail

log() { printf "\n==> %s\n" "$*"; }

if [[ "${OSTYPE:-}" != "darwin"* ]]; then
  echo "This bootstrap is intended for macOS. OSTYPE=${OSTYPE:-unknown}"
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WITH_K8S=0
WITH_BUILD=0
WITH_CONTAINERS=0
WITH_GUI=0

for arg in "$@"; do
  case "$arg" in
    --k8s) WITH_K8S=1 ;;
    --build) WITH_BUILD=1 ;;
    --containers) WITH_CONTAINERS=1 ;;
    --gui) WITH_GUI=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: ./bootstrap.sh [--k8s] [--build] [--containers] [--gui]

Installs:
  Core (always): Brewfile
  Optional:
    --k8s        Brewfile.k8s
    --build      Brewfile.build
    --containers Brewfile.containers
    --gui        Brewfile.gui
EOF
      exit 0
      ;;
    *)
      echo "Unknown arg: $arg"
      exit 1
      ;;
  esac
done

BREWFILE_CORE="$DOTFILES_DIR/Brewfile"
BREWFILE_K8S="$DOTFILES_DIR/Brewfile.k8s"
BREWFILE_BUILD="$DOTFILES_DIR/Brewfile.build"
BREWFILE_CONTAINERS="$DOTFILES_DIR/Brewfile.containers"
BREWFILE_GUI="$DOTFILES_DIR/Brewfile.gui"

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew found: $(command -v brew)"
    return
  fi

  log "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "brew installed but not found on PATH"
    exit 1
  fi
}

bundle_file() {
  local file="$1"
  local label="$2"
  if [[ ! -f "$file" ]]; then
    echo "Missing $label at: $file"
    exit 1
  fi
  log "brew bundle ($label): $file"
  brew bundle --file "$file"
}

add_line_if_missing() {
  local line="$1"
  local file="$2"
  grep -Fq "$line" "$file" || echo "$line" >> "$file"
}

ensure_shell_hooks() {
  local zshrc="$HOME/.zshrc"
  local zsh_local="$HOME/.zshrc.local"
  touch "$zsh_local"

  log "Ensuring ~/.zshrc sources ~/.zshrc.local"
  local source_line='[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"'
  if [[ -f "$zshrc" ]]; then
    grep -Fq "$source_line" "$zshrc" || {
      echo "" >> "$zshrc"
      echo "# Local overrides (not in git)" >> "$zshrc"
      echo "$source_line" >> "$zshrc"
    }
  else
    {
      echo "# Local overrides (not in git)"
      echo "$source_line"
    } > "$zshrc"
  fi

  log "Writing hooks to ~/.zshrc.local (no duplicates)"
  add_line_if_missing '# mise' "$zsh_local"
  add_line_if_missing 'eval "$(mise activate zsh)"' "$zsh_local"
  add_line_if_missing '' "$zsh_local"
  add_line_if_missing '# zoxide' "$zsh_local"
  add_line_if_missing 'eval "$(zoxide init zsh)"' "$zsh_local"
  add_line_if_missing '' "$zsh_local"
  add_line_if_missing '# direnv' "$zsh_local"
  add_line_if_missing 'eval "$(direnv hook zsh)"' "$zsh_local"
}

configure_fzf() {
  local fzf_install
  fzf_install="$(brew --prefix)/opt/fzf/install"
  if [[ -x "$fzf_install" ]]; then
    log "Configuring fzf keybindings/completion (no shell rc changes)..."
    "$fzf_install" --no-bash --no-fish --key-bindings --completion --no-update-rc || true
  fi
}

main() {
  ensure_brew

  log "Updating Homebrew..."
  brew update

  bundle_file "$BREWFILE_CORE" "core"

  [[ "$WITH_K8S" -eq 1 ]] && bundle_file "$BREWFILE_K8S" "k8s"
  [[ "$WITH_BUILD" -eq 1 ]] && bundle_file "$BREWFILE_BUILD" "build"
  [[ "$WITH_CONTAINERS" -eq 1 ]] && bundle_file "$BREWFILE_CONTAINERS" "containers"
  [[ "$WITH_GUI" -eq 1 ]] && bundle_file "$BREWFILE_GUI" "gui"

  configure_fzf
  ensure_shell_hooks

  log "Done."
  log "Restart terminal or run: source ~/.zshrc"
}

main
