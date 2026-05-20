# zsh completion system (must load before anything calling compdef)
autoload -Uz compinit
compinit

# Local overrides (not in git)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# Homebrew, MySQL, Python user scripts, Java, jenv
export PATH="/opt/homebrew/bin:/opt/homebrew/opt/mysql-client/bin:$HOME/Library/Python/3.9/bin:$JAVA_HOME/bin:$HOME/.jenv/bin:$PATH"

# Optional: CLICOLOR
export CLICOLOR=1

# Java versions
export JAVA_HOME_25="/opt/homebrew/Cellar/openjdk/25.0.1/libexec/openjdk.jdk/Contents/Home"
export JAVA_HOME_21="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export JAVA_HOME_17="/opt/homebrew/Cellar/openjdk@17/17.0.17/libexec/openjdk.jdk/Contents/Home"

# Set default Java (e.g., JDK 21)
# export JAVA_HOME=$JAVA_HOME_21
# Set default Java (e.g., JDK 17)
export JAVA_HOME=$JAVA_HOME_17
eval "$(jenv init -)"

# Starship prompt
eval "$(starship init zsh)"

# Git Aliases
alias gs='git status'
alias gsw='git switch'
alias glog='git log --oneline'
alias gg='git push -u origin $(git symbolic-ref --short HEAD)'
alias ggff='git push -u origin $(git symbolic-ref --short HEAD) --force-with-lease'
alias gpull='git pull origin'
alias gpmain='git pull origin main'
alias ga='git add'
alias lg='lazygit'

# Docker Aliases
alias psdocker="docker ps"
alias psadocker="docker ps -a"
alias attachdocker="docker attach"
alias execdocker="docker exec -it"
alias logsdocker="docker logs -f"
alias rmdocker="docker rm -f"
alias imagesdocker="docker images"
alias rmidocker="docker rmi -f"
alias updocker="docker-compose up -d"
alias startdocker="docker-compose start"
alias dddocker="docker-compose down"
alias resdocker="docker-compose restart"

# Kitty ssh
alias ks="kitty +kitten ssh"

# Custom aliases (add here!)
# ------------------------ Start --------------------------
alias brewupd='brew update && brew upgrade && brew cleanup'
alias reload='source ~/.zshrc'
alias poweroff='sudo shutdown -h now'

alias kill8080='lsof -ti:8080 | xargs -r kill -9'
killport() { lsof -ti:$1 | xargs -r kill -9; }

getappid() {
    osascript -e "id of app \"$1\""
}

# Switch between JDK versions
alias usejdk17='export JAVA_HOME=$JAVA_HOME_17 && export PATH=$JAVA_HOME/bin:$PATH'
alias usejdk21='export JAVA_HOME=$JAVA_HOME_21 && export PATH=$JAVA_HOME/bin:$PATH'
alias usejdk25='export JAVA_HOME=$JAVA_HOME_25 && export PATH=$JAVA_HOME/bin:$PATH'

# Quarkus
alias qd="./mvnw quarkus:dev"

# Antigravity IDE
alias ag="antigravity"

# Terraform
alias tf-init="terraform init -backend=false"
alias tf-plan="terraform plan -var-file=local._override.tfvars"
alias tf-apply="terraform apply -var-file=local._override.tfvars"

# Bun
alias b="bun"
alias bi="bun install"
alias bd="bun turbo dev"

# Core
alias p="pnpm"
alias pni="pnpm install"
alias pa="pnpm add"
alias pad="pnpm add -D"
alias px="pnpm exec"

# Scripts
alias pdev="pnpm run dev"
alias pbuild="pnpm run build"
alias pstart="pnpm run start"

# Reset
alias pclean="rm -rf node_modules pnpm-lock.yaml"
alias preinstall="pclean && pnpm install"

# System
alias sleepnow="sudo pmset sleepnow"

alias ocreview='opencode -p "MODE: REVIEW-ONLY

Rules:
- Do NOT edit files.
- Do NOT run commands.
- Analysis and reasoning only.

Task:"'

alias ocexec='opencode -p "MODE: EXECUTE-ONLY

Rules:
- Execute the approved plan exactly.
- Do NOT introduce new design decisions.
- Ask before unapproved steps.

Task:"'

# fzf
frg() {
  local file
  file=$(rg --line-number --no-heading --color=always "" \
    | fzf --ansi --delimiter : \
      --preview 'bat --style=numbers --color=always {1} --line-range {2}:+20')
  [[ -n "$file" ]] && nvim "$(echo "$file" | cut -d: -f1)"
}

alias ff='fd --type f | fzf --preview "bat --style=numbers --color=always {}"'

fbr() {
  local branch
  branch=$(git branch --all | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf)
  [[ -n "$branch" ]] && git checkout "$branch"
}

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  [[ -n "$pid" ]] && kill -9 $pid
}

# zellij
zj() {
  [ -n "$ZELLIJ" ] && return
  local dir
  dir=$(fd --type d --max-depth 3 . ~/Projects ~/Personal 2>/dev/null | tv) || return
  (cd "$dir" && zellij attach -c "$(basename "$dir" | tr . _)")
}

zl() {
    local session
    
    session=$(zellij list-sessions -n 2>/dev/null | tv | awk '{print $1}')

    if [[ -n "$session" ]]; then
        echo "Attaching to: $session..."
        zellij attach "$session"
    fi
}

alias ls='eza --group-directories-first --icons'
alias ll='eza -lh --git --icons --group-directories-first'
alias la='eza -lah --git --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
export EZA_COLORS="di=34:fi=250:ex=40:ln=44"

# Claude code
alias cc="claude --dangerously-skip-permissions"

# GNU
alias g++='g++-15 -std=c++23 -O2 -Wall -Wextra -DLOCAL -I/usr/local/include'

# ------------------------ End ---------------------------

# Add JBang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"

# Added by Antigravity
export PATH="/Users/shisoya/.antigravity/antigravity/bin:$PATH"

# opencode
export PATH=/Users/shisoya/.opencode/bin:$PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# pnpm
export PNPM_HOME="/Users/shisoya/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# mise
eval "$(mise activate zsh)"

# direnv
eval "$(direnv hook zsh)"


. "$HOME/.local/bin/env"
source $HOME/.local/bin/env
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/shisoya/.antigravity/antigravity/bin:$PATH"

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Television
eval "$(tv init zsh)"

# Zoxide
eval "$(zoxide init --cmd cd zsh)"
source /Users/shisoya/.config/broot/launcher/bash/br

# Atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
