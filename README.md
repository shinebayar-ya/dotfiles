# dotfiles

macOS (Apple Silicon) dev environment as code. chezmoi for files, Homebrew Bundle for packages, mise for runtimes, just as the CLI.

## New machine

```bash
git clone git@github.com:shinebayar-ya/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh work        # or: home
~/dotfiles/bootstrap.sh work --dry-run
```

Bootstrap installs Homebrew, chezmoi and just, writes `~/.config/chezmoi/chezmoi.toml` (profile), applies files, runs `brew bundle` (shared + profile) and `mise install`. Safe to re-run.

Then create `~/.gitconfig.local` (name, email, signing) and `~/.zshrc.local` (tokens). Both stay untracked.

## Daily use

| Command | What |
|---------|------|
| `just diff` | repo vs home, before applying |
| `just apply` | write files, install packages |
| `just save` | copy edits from live files back to the repo (`chezmoi re-add`) |
| `just pkgs` | packages missing from this Mac, and installed ones in no manifest |
| `just doctor` | machine health: tools, profile, symlinks, ssh, shell startup, PATH |
| `just verify` | repo checks: render work+home, syntax, secrets, ignore rules, manifests |

Edit either side. Repo first: edit under `home/`, `just apply`. Live first: edit the file, `just save`.

## Profiles

`work` or `home`, stored in `~/.config/chezmoi/chezmoi.toml` as `profile`. Set once at bootstrap (or `DOTFILES_PROFILE=home chezmoi init`).

| | work | home |
|---|---|---|
| packages | `Brewfile.shared` + `Brewfile.work` | `Brewfile.shared` + `Brewfile.home` |
| `.zshrc` | Java/jenv, JDK aliases, Quarkus, MySQL/libpq PATH, terraform aliases | none of those |
| `~/.ssh/config` | adds `lendbeta` host | GitHub only |

Everything else is identical. Templates are used only where the profile matters (`dot_zshrc.tmpl`, `private_dot_ssh/config.tmpl`, Claude settings merge).

## Layout

See [docs/architecture.md](docs/architecture.md).
