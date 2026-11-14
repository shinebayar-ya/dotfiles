---
description: Write living reference doc (design, cron, deploy, status/reason codes) to cc-docs/<topic>/YYYYMMDD-N-<slug>.md.
argument-hint: <what to document | file:line | symbol> [--update]
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(ls:*), Bash(date:*), Bash(git rev-parse:*), Bash(pwd)
---

# Wiki

Subject: $ARGUMENTS

Empty subject → use what we were just talking about. Nothing there → ask one line: what to document.

## Type

`cc-docs` = living reference. Stays true until code changes: design, flow, cron schedule, deploy/migration steps, config, status/reason codes, endpoint contract. Point-in-time finding (review, audit, debug) → `/sniff`. Explaining a concept → `/what`.

## Flags

Strip from Subject. Default off.

- `--update` — edit the existing doc on this topic in place instead of a new file. Also the default when the same doc already exists.

## Rules

- Read the real code first. Name real files, functions, constants, routes. Never invent paths or APIs. Unknown → `Open questions` at bottom.
- Facts only. Mark inference as `(inferred)`.
- Only file written: the doc. No code edits.
- No real secrets, tokens, PII, prod data. Mock values.

## File

- Root: repo root of the subject (`git rev-parse --show-toplevel`), else cwd.
- Dir `cc-docs/<topic>/` in root, create if missing. Topic = logical area, kebab 1-2 words (`autopay`, `invoice`). Reuse existing: `ls cc-docs/`.
- Name `YYYYMMDD-N-<slug>.md`. Date = `date +%Y%m%d`. N = highest N in that topic folder + 1 (1 if empty). Slug English kebab 2-4 words → `cc-docs/autopay/20261012-3-autopay-cron.md`.
- Same doc already exists (Glob `cc-docs/<topic>/*.md`, same subject) → Edit it, keep its name. Never rename.
- Links to other docs: full path from repo root, `cc-docs/<topic>/<file>`; cross-repo `<repo>/cc-docs/...`.

## Style

Mongolian prose. Technical terms stay English (cron, migration, idempotency, outbox). Code, identifiers, commands, errors unchanged. Caveman + unslop: start with the point, no intro/outro, no filler. Short sentences, bullets, tables for enums/codes. `file:line` refs. Code only for signatures, schemas, SQL, commands.

## Template

```markdown
# <Subject> — <aspect>

<1-2 lines: what it is, who owns it>

## <Flow | Schedule | Contract | Codes>
<bullets / table>

## Deploy / Config
<only if real>

## Open questions
- <question | drop section>
```

Sections with nothing real → drop. Never pad.

## Output — one line

```
cc-docs/<topic>/<YYYYMMDD-N-slug>.md — <created|updated>
```
