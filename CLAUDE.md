# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repo purpose

macOS dev environment as code. chezmoi (files), Homebrew Bundle (packages), mise (runtimes), just (CLI). Work and home profiles. Details: `README.md`, `docs/architecture.md`.

## Layout

- `.chezmoiroot` = `home`: chezmoi source is `home/`, mirrors `$HOME` with chezmoi names (`dot_zshrc.tmpl` → `~/.zshrc`, `dot_config/nvim/` → `~/.config/nvim/`, `private_`, `executable_`).
- `brew/Brewfile.{shared,work,home}` + `brew/untracked.txt` (installed on purpose, in no manifest).
- `bootstrap.sh <work|home> [--dry-run]`, idempotent.
- `justfile`: `diff`, `apply`, `save`, `pkgs`, `doctor`, `verify`.

Files are copied, not symlinked. Edit under `home/` then `just apply`, or edit the live file then `just save`. Don't re-add stow or tmux config.

## Profiles

`profile` (`work`|`home`) lives in `~/.config/chezmoi/chezmoi.toml`. Use templates only where it matters (`dot_zshrc.tmpl`, `private_dot_ssh/config.tmpl`). Company stuff (Java/jenv, Quarkus, terraform, MySQL, `lendbeta` ssh host) is work-only. Home stays lean.

## Tool-owned files

Never manage whole: `~/.claude/settings.json` (merged by `modify_private_settings.json`, portable keys in `.chezmoitemplates/claude-settings.json`), `~/.codex/config.toml`, anything holding tokens/sessions/history. Secrets live in untracked `~/.zshrc.local`.

## Brewfile profiles

Adding a tool: smallest manifest that fits. `just pkgs` shows missing and unmanaged. Don't remove installed apps for being absent from a manifest.

## Theme (unified)

Catppuccin Frappe everywhere. User wears orange-tinted glasses: warm low-blue palette, keep contrast high, no pure-blue text on dark, no light themes. Keep new config consistent with it.

Theme switch = edit every row below, then `just apply`.

| Tool | File | Key |
|------|------|-----|
| ghostty | `home/dot_config/ghostty/config` | `theme = Catppuccin Frappe`; keep `minimum-contrast = 4.5` (lifts dim blues and dark-tuned ANSI logs, e.g. Quarkus) |
| zellij | `home/dot_config/zellij/config.kdl` | `theme "catppuccin-frappe"` (built-in, no `themes {}` block) |
| nvim | `home/dot_config/nvim/lua/plugins/colorscheme.lua` | `catppuccin/nvim` (`name = "catppuccin"`), `flavour = "frappe"` |
| nvim | `home/dot_config/nvim/lua/core/options.lua` | `opt.background = "dark"` |
| nvim | `home/dot_config/nvim/lua/plugins/lualine.lua` | `theme = 'auto'` (no built-in catppuccin lualine theme) |
| bat | `home/dot_config/bat/config` | `--theme="Catppuccin Frappe"` (built-in) |
| delta | `home/dot_gitconfig` | `[delta]` `dark = true`, `syntax-theme = Catppuccin Frappe` (same bat theme list) |
| atuin | `home/dot_config/atuin/config.toml` + `home/dot_config/atuin/themes/<name>.toml` | `[theme] name`; hex colors in the theme file |
| eza | `home/dot_zshrc.tmpl` | `EZA_COLORS`, truecolor fg codes only (no bg codes) |
| claude code | `home/dot_claude/themes/<name>.json` + `theme` in `~/.claude/settings.json` (untracked) | `custom:<name>`; `claude` = accent, `suggestion` = selection highlight, `userMessageBackground` = message bg; restart once if `~/.claude/themes` is new |
| television (tv) | `home/dot_config/television/config.toml` + `themes/catppuccin-frappe.toml` | `theme = "catppuccin-frappe"`; hex colors in the theme file |
| starship | `home/dot_config/starship.toml` | named ANSI colors only, follows terminal palette — no edit needed |

New tool with a theme → add a row here.

## Neovim config

Plugin manager: `lazy.nvim` (auto-bootstraps in `init.lua`). Leader = space.

Layout under `home/dot_config/nvim/`:
- `init.lua` — lazy bootstrap, plugin import, template autocmds
- `lua/core/{options,keymaps}.lua` — base vim settings
- `lua/plugins/*.lua` — one file per plugin spec; lazy auto-imports `plugins/`
- `lua/plugins/lsp/{lspconfig,mason,none-ls}.lua` — LSP subdir, imported via `{ import = "plugins.lsp" }` in `lua/plugins/init.lua`
- `ftplugin/java.lua` — filetype-local config (jdtls)
- `templates/` — `template.{c,cc,cpp,py}` auto-inserted on `BufNewFile` for matching extension, plus `leetcode.cpp`

Adding a plugin: drop a new file in `lua/plugins/`. LSP-related: put in `lua/plugins/lsp/` (auto-imported).

`lazy-lock.json` committed — preserve on plugin updates.

## Zsh shape

`home/dot_zshrc.tmpl` intentionally not modular — single file, order matters:

1. Sources `~/.zshrc.local` first (secrets, untracked)
2. One `path=(...)` block with `typeset -U path` (no other PATH edits), then `JAVA_HOME`/jenv (work)
3. Aliases (git, docker) + custom block marked `# Start ... # End`; work-only aliases gated by `{{ if eq .profile "work" }}`
4. Functions: `killport`, `getappid`, `frg`, `fbr`, `fkill`, `zj`/`zl`
5. Tail: `compinit` FIRST (tv and zoxide call `compdef` at init), then mise, direnv, tv, zoxide, broot, atuin

`~/.zprofile` (`dot_zprofile`) only sources OrbStack init.

## Git config

`home/dot_gitconfig` = tracked baseline. Identity / signing in untracked `~/.gitconfig.local`. No email/signing in tracked files.

## When editing

- Files under `home/` must mirror the `$HOME` destination via chezmoi names.
- No machine-specific values (`/Users/<name>`, tokens, emails) in tracked files. Use `$HOME`, `~`, `{{ .chezmoi.homeDir }}`.
- `bootstrap.sh` must stay idempotent.
- No explanatory comments in configs — title/group comments only, matching the file's existing pattern.
- Repo `.gitignore` re-includes `CLAUDE.md` and `.claude/` (global ignore skips them).
- Verify after every change: `just verify` (renders both profiles, syntax, gitleaks, ignore rules, manifests), `just doctor`, `chezmoi status`.
