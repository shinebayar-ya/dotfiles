# Architecture

## Tree

```
~/dotfiles
├── .chezmoiroot          "home": chezmoi source is home/, everything else is repo tooling
├── bootstrap.sh          first-run installer
├── justfile              diff / apply / save / pkgs / doctor / verify
├── brew/
│   ├── Brewfile.shared   every machine
│   ├── Brewfile.work     work only
│   ├── Brewfile.home     home only
│   └── untracked.txt     installed on purpose, deliberately in no manifest
└── home/                 mirrors $HOME with chezmoi names (dot_, private_, executable_)
    ├── .chezmoi.toml.tmpl    profile prompt/env -> ~/.config/chezmoi/chezmoi.toml
    ├── .chezmoitemplates/    claude-settings.json (portable Claude keys)
    ├── dot_zshrc.tmpl, dot_zprofile, dot_gitconfig, dot_gitignore_global
    ├── private_dot_ssh/config.tmpl
    ├── dot_claude/   CLAUDE.md, rules, commands, agents, skills, themes, own hooks, settings merge
    ├── dot_codex/    AGENTS.md, keybindings.json
    └── dot_config/   nvim ghostty zellij kitty zed aerospace karabiner herdr herdr-app (keys, settings) opencode
                      atuin bat broot gh mise starship television topgrade
```

## Ownership rules

- One owner per file. chezmoi copies files (no symlinks); the repo is the source of truth, `just save` pulls live edits back.
- Tool-written files are not managed whole:
  - `~/.claude/settings.json`: `modify_private_settings.json` merges only portable keys (theme, model, statusLine, editor, env, three plugins, marketplaces) and ensures the `strip-ai-attribution` hook. Permissions, other plugins and hooks written by atuin / repowise / context-mode / herdr stay local.
  - `~/.codex/config.toml`, `hooks.json`: Codex app rewrites them (absolute paths, project trust, hook hashes). Not managed.
- Never managed: credentials, tokens, keys, auth DBs, sessions, history, caches, logs, `node_modules`, `~/.zshrc.local`, `~/.gitconfig.local`, `~/.ssh` keys and `known_hosts`, `gh/hosts.yml`.
- Not managed (tool-owned or ephemeral): plugin-installed hooks/skills (caveman, context-mode, `~/.agents`, `skills/synced`), btop.conf (rewritten on exit), Karabiner `automatic_backups`, broot `launcher/`, herdr sessions.
- Paths: use `$HOME`, `~`, `{{ .chezmoi.homeDir }}`, `$HOMEBREW_PREFIX`. No `/Users/<name>` in tracked files.

## Runtimes

mise owns node (`~/.config/mise/config.toml`) and per-project tools. Java stays on jenv + Homebrew JDKs: jenv is wired to `JAVA_HOME` and the `usejdk*` aliases, and no mise-installed JDK was shown to be a drop-in for the existing projects. Revisit when a project pins Java in `.mise.toml`.

## Git ignore

`~/.gitignore_global` ignores `CLAUDE.md` and `.claude/` everywhere. This repo's `.gitignore` re-includes both, and `just verify` fails if any file under the repo is untracked or ignored.

## Recovery

Before the migration a snapshot was written to `~/.dotfiles-snapshots/<timestamp>/` (repo tarball, home config tarball, `Brewfile.installed`, mise state). Restore with `tar -xzf home-dotfiles.tgz -C ~`.
