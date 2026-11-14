---
description: New branch from current work. Name from argument, or from diff.
argument-hint: [name]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git branch:*), Bash(git switch:*), Bash(git rev-parse:*), Bash(head:*)
---

# New branch

Arg: `$ARGUMENTS`

## Context (loaded, do not re-run)

- Current: !`git branch --show-current`
- Status: !`git status --short`
- Diff stat: !`git diff HEAD --stat`
- Diff: !`git diff HEAD | head -300`
- Recent branches: !`git branch --sort=-committerdate --format='%(refname:short)' | head -8`

## Name

Format `<type>/<kebab-slug>`. Type: `feat fix refactor docs test chore` (or repo's own prefixes if CLAUDE.md/AGENTS.md lists them).

- Arg with type (`fix/login-null`) → use as is.
- Arg without type (`login null`) → kebab-case it, type from diff (no diff → `feat`).
- No arg → name the main change in diff:
  - new behavior / file / endpoint → `feat`
  - wrong value, guard, crash → `fix`
  - same behavior, moved/renamed → `refactor`
  - only docs → `docs`; only tests → `test`; config/CI/deps → `chore`
- Slug: 2-4 words, `a-z0-9-`, domain words from diff, no filler (`update`, `changes`, `misc`, `wip`).
- Follow recent branch style.

## Run

1. No arg and no changes → STOP, ask name in one line.
2. Name exists (`git rev-parse --verify --quiet refs/heads/<name>`) → add `-2`.
3. `git switch -c <name>` — uncommitted changes carry over. Never stash, commit, reset.

## Output — one line

```
<old> → <name> (<N> files carried)
```
