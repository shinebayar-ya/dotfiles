---
description: Rebase current branch onto origin/<branch> (default dev). Auto-fix trivial conflicts, stop on logic conflicts.
argument-hint: [branch]
allowed-tools: Bash(git fetch:*), Bash(git rebase:*), Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git rev-parse:*), Bash(git grep:*), Bash(git branch:*), Bash(git log:*), Read, Edit
---

# Rebase

Target: `origin/$1`. Argument empty → `origin/dev`.

## Context

- Branch: !`git branch --show-current`
- Status: !`git status --short`

## 1. Preflight — stop on fail, one line why

- Status not empty → STOP. Ask: stash, commit, or abort. Never stash yourself.
- Rebase in progress (`git rev-parse --git-path rebase-merge` dir exists) → STOP. Ask: continue or abort.
- Detached HEAD, or branch == target → STOP.
- Save `ORIG=$(git rev-parse HEAD)` for rollback.

## 2. Run

```bash
git fetch origin
git rebase origin/<target>
```

Target missing on origin → STOP, show `git branch -r`.

## 3. Conflicts — loop until done

Per file in `git diff --name-only --diff-filter=U`, read hunks, classify.

**Trivial — fix, `git add`, `GIT_EDITOR=true git rebase --continue`:**
- whitespace, indent, trailing comma, line wrap, quote style
- both sides added different imports / independent list or map entries (no key clash) → keep both
- identical change both sides
- lockfile / generated file → take target side, regenerate if tool present

**Logic — PAUSE, ask:**
- same line, different values (condition, number, string, key, name)
- one side deleted/renamed what the other edited
- signature or behavior differs
- any doubt → logic

Ask format, per hunk, nothing else:

```
<file>:<line> — <commit being applied>
target: <short code>
mine:   <short code>
Why: <one line>
1) target  2) mine  3) <one-line merge proposal>  4) abort
```

## 4. Verify

- `git grep -nE '^(<<<<<<<|=======|>>>>>>>)( |$)'` → must be empty.
- Repo has lint/test gate (see CLAUDE.md / AGENTS.md / package.json) → run it. Fail → report, no silent fix.

## 5. Report — max 5 lines

```
<branch> on origin/<target>: <N> commits replayed
Auto-fixed: <file — reason> | none
Asked: <file — choice> | none
Gate: pass | fail <first error> | none
Rollback: git reset --hard <ORIG>
```

## Never

- push, `--force`, `--force-with-lease`
- `git rebase --skip`, drop/squash/reword commits
- `--no-verify`
- guess on logic conflict
