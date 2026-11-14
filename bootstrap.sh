#!/usr/bin/env bash
# Usage: ./bootstrap.sh <work|home> [--dry-run]
set -euo pipefail

log() { printf '\n==> %s\n' "$*"; }
run() { if [[ $dry == 1 ]]; then echo "+ $*"; else "$@"; fi; }

[[ ${OSTYPE:-} == darwin* ]] || { echo "macOS only"; exit 1; }

dry=0 profile=${DOTFILES_PROFILE:-}
for a in "$@"; do
  case $a in
    work|home) profile=$a ;;
    --dry-run) dry=1 ;;
    -h|--help) sed -n '2p' "$0"; exit 0 ;;
    *) echo "unknown arg: $a"; exit 1 ;;
  esac
done
[[ -n $profile ]] || { echo "profile required: ./bootstrap.sh work|home"; exit 1; }

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[[ $root == "$HOME/dotfiles" ]] || { echo "clone the repo to ~/dotfiles (now: $root)"; exit 1; }
export DOTFILES_PROFILE=$profile

if ! command -v brew >/dev/null; then
  log "install Homebrew"
  run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

for t in chezmoi just; do
  command -v $t >/dev/null || { log "install $t"; run brew install $t; }
done

log "chezmoi init ($profile)"
run chezmoi init --source "$root"

if [[ $dry == 1 ]]; then
  log "pending changes"
  chezmoi diff || true
  log "packages (check also reports outdated)"
  brew bundle check --file "$root/brew/Brewfile.shared" || true
  brew bundle check --file "$root/brew/Brewfile.$profile" || true
  exit 0
fi

log "chezmoi apply"
chezmoi apply

log "brew bundle"
brew bundle --file "$root/brew/Brewfile.shared"
brew bundle --file "$root/brew/Brewfile.$profile"

log "mise install"
mise install

log "done: open a new shell, then run: just doctor"
