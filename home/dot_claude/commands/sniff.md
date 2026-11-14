---
description: Write point-in-time report (code review, audit, debug, investigation) to cc-reports/<topic>/YYYYMMDD-N-<slug>.md.
argument-hint: <what was reviewed or investigated | MR !123 | file | error>
allowed-tools: Read, Grep, Glob, Write, Bash(ls:*), Bash(date:*), Bash(git rev-parse:*), Bash(git log:*), Bash(git diff:*), Bash(pwd)
---

# Sniff

Subject: $ARGUMENTS

Empty subject → use what we were just doing (review, debug, investigation). Nothing there → ask one line: what to report.

## Type

`cc-reports` = snapshot of findings at one moment. Never edited later. Code review, MR review, audit, debug trace, incident, investigation, benchmark. Stays-true reference (design, cron, deploy) → `/wiki`. Task list → `/todo`.

## Rules

- Report what was actually checked. Distinguish: **Баталгаатай** (verified in code/output), **Таамаг** (inference), **Шалгаагүй** (not checked). Never present inference as fact.
- Cite evidence: `file:line`, command output, commit hash, MR number. Never invent.
- Findings ranked by severity: 🔴 bug/security/data loss, 🟡 risk/perf, 🔵 nit. Each: where, what breaks, fix.
- Only file written: the report. No code edits.
- No real secrets, tokens, PII, prod data. Mask them.

## File

- Root: repo root of the subject (`git rev-parse --show-toplevel`), else cwd.
- Dir `cc-reports/<topic>/` in root, create if missing. Topic = logical area, kebab 1-2 words (`settlement`, `deploy`). Reuse existing: `ls cc-reports/`.
- Name `YYYYMMDD-N-<slug>.md`. Date = `date +%Y%m%d`. N = highest N in that topic folder + 1. Slug English kebab 2-5 words → `cc-reports/settlement/20261005-2-mr-967-review-02.md`.
- Follow-up on earlier report → new file, link previous by full path. Never overwrite.

## Style

Mongolian prose. Technical terms stay English. Code, identifiers, errors unchanged. Caveman + unslop: verdict first, no intro, no filler. Bullets, tables for findings.

## Template

```markdown
# <Subject> — <review | audit | debug>

- **Хамрах хүрээ:** <MR/commit/files/env>
- **Огноо:** <YYYY-MM-DD>
- **Өмнөх тайлан:** <path | drop>

## Дүгнэлт
<1-3 lines: verdict, top risk>

## Findings
| # | Severity | Where | Problem | Fix |
|---|---|---|---|---|

## Баталгаатай / Таамаг / Шалгаагүй
- ...

## Next steps
- <action | drop>
```

Empty section → drop.

## Output — one line

```
cc-reports/<topic>/<YYYYMMDD-N-slug>.md — <N> findings
```
