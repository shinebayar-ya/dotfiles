---
description: Write implementation plan to cc-plans/<topic>/YYYYMMDD-N-<feature>.md. No code run, no code written.
argument-hint: <feature context> [--review]
allowed-tools: Read, Grep, Glob, Write, Bash(ls:*), Bash(date:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*)
---

# Implementation plan

Feature: $ARGUMENTS

Empty feature → STOP, ask one line: what to plan.

## Flags

Strip flags from Feature before planning. Default off.

- `--review` — add two last steps after verify: `/simplify` on diff (apply findings), then `/code-review` on diff (no open findings). Add `## Done when` section listing them. Absent → no review steps, no `Done when`.

## Rules

- Read-only on code. Only file written: the plan.
- No running app, tests, builds, migrations.
- Read enough code to name real files, functions, patterns. Never invent paths or APIs.
- Never guess. Vague requirement, missing business rule, 2+ valid designs, unverifiable fact → Open question. Never pick silently, never bury an assumption in Steps.
- Step that depends on an open question → mark `(blocked: Q#)`. Unblocked steps stay concrete.
- Resolve `/oq <plan>` after planning to close the questions with the user.
- Reuse first: existing helper/pattern/dep before new code. Say which.

## File

- Dir `cc-plans/<topic>/` at repo root, create if missing. Topic = logical area, kebab 1-2 words (`autopay`, `contract`). Reuse existing topic folder if one fits: `ls cc-plans/`.
- Existing plans: Glob `cc-plans/<topic>/*.md`.
- Name: `YYYYMMDD-N-<slug>.md`. Date = today. N = next number in that topic folder (1, 2, ...). Slug kebab 2-4 words → `cc-plans/contract/20261012-3-termination.md`.

## Style

Caveman. Technical bullets. No intro, no summary prose, no filler (`robust`, `comprehensive`, `seamless`, `leverage`, `ensure`). Fragments OK. `file:line` refs. Code only for signatures/schemas.

## Template

```markdown
# <Feature>

Goal: <one line>
Out of scope: <bullets | none>

## Touch
- `path/file` — <what changes>

## Steps
1. <action> — `file` — <detail>
2. ...

## Done when (`--review` only)
- Tests green
- `/simplify` on diff — clean, or findings applied
- `/code-review` on diff — no open findings

## Data / API
- <schema, endpoint, contract change | none>

## Tests
- <case> — `test/file`

## Risks
- <risk> — <mitigation>

## Decisions
- none

## Open questions
- Q1: <question> — A <option> / B <option> — lean: <A|B|none> (<why, one line>) — blocks: step <N>
- <none>
```

## Output — one line

```
cc-plans/<topic>/<YYYYMMDD-N-slug>.md — <N> steps, <M> open questions
```
