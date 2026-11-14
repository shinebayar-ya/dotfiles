---
description: Write TODO / checklist to cc-tasks/<topic>/YYYYMMDD-N-<slug>.md.
argument-hint: <what to track | list of items>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(ls:*), Bash(date:*), Bash(git rev-parse:*), Bash(pwd)
---

# Todo

Items: $ARGUMENTS

Empty → use open work from this conversation (what is left, follow-ups, deferred). Nothing there → ask one line: what to track.

## Type

`cc-tasks` = checklist of work to do. Not a plan with design (→ `/iplan`), not a finding (→ `/sniff`).

## Rules

- One checkbox = one doable action, verb first. Split anything that takes more than one sitting.
- Real names only: file, endpoint, ticket (`LSD-1234`). Never invent.
- Only file written: the task file. No code edits.
- Check off done items (`- [x]`) when asked or when this session just finished them.

## File

- Root: repo root (`git rev-parse --show-toplevel`), else cwd.
- Dir `cc-tasks/<topic>/` in root, create if missing. Topic = logical area, kebab 1-2 words. Reuse existing: `ls cc-tasks/`.
- Name `YYYYMMDD-N-<slug>.md`. Date = `date +%Y%m%d`. N = highest N in that topic folder + 1. Slug English kebab 2-4 words → `cc-tasks/autopay/20261012-1-rollout.md`.
- Open task file on same topic exists (has `- [ ]`) → Edit it, add items, keep name. Never rename.

## Style

Mongolian. Technical terms English. Caveman: short, no filler.

## Template

```markdown
# <Topic> — tasks

## Хийх
- [ ] <action> — `file`/ticket

## Хүлээж байгаа
- [ ] <blocked item> — <blocked by>

## Дууссан
- [x] <action>
```

Empty section → drop.

## Output — one line

```
cc-tasks/<topic>/<YYYYMMDD-N-slug>.md — <open> open, <done> done
```
