# dotfiles

macOS development setup.

This repo manages:

- shell config (zsh)
- git config
- tmux
- nvim
- ghostty
- CLI tools via Homebrew
- optional profiles (k8s, build, containers, gui)

Everything is reproducible on a new machine.

---

## Structure

- `zsh/` → `.zshrc`
- `git/` → `.gitconfig`
- `tmux/` → `.tmux.conf`
- `nvim/` → `.config/nvim`
- `ghostty/` → `.config/ghostty`
- `Brewfile*` → Homebrew packages
- `bootstrap.sh` → machine setup script

We use:

- **stow** for symlink management
- **brew bundle** for package installation
- **.zshrc.local** and **.gitconfig.local** for machine-specific settings

---

## New Machine Setup (macOS)

1. Clone repo:

```bash
git clone git@github.com:shinebayar-ya/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Run bootstrap (core only):

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```


## Optional profiles:

```bash
./bootstrap.sh --k8s --build --containers --gui
```

Done.
