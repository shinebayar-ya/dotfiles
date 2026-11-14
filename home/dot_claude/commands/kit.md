---
description: Write sample data, query/script, or export file (json, csv, sql, xlsx input) to cc-data/<topic>/YYYYMMDD-N-<slug>.<ext>.
argument-hint: <what data/script> [ext]
allowed-tools: Read, Grep, Glob, Write, Bash(ls:*), Bash(date:*), Bash(git rev-parse:*), Bash(pwd)
---

# Kit

Subject: $ARGUMENTS

Empty → use data/script we were just discussing. Nothing there → ask one line: what to save.

## Type

`cc-data` = artifacts that are data, not prose: sample JSON, CSV, one-off `.sql`, fixtures, query snippets, payload examples. Prose explaining them → `/wiki`.

## Rules

- Ext from the request or content: `json`, `csv`, `sql`, `txt`. Default `json` for payloads, `sql` for queries. Binary (xlsx) is not generated here — user drops those in, `/kit` only names/places them.
- **Mock data only.** Never real PII, secrets, tokens, prod rows. Replace with obvious fakes (`user-1`, `99001122`, `example.com`). User pastes something real-looking → flag it, mask it, tell them to rotate if it is a secret.
- Valid syntax: `json` parses, `sql` matches schema in repo (check real table/column names; never invent).
- Destructive SQL (`DELETE`, `UPDATE`, `DROP`, `TRUNCATE`) → first line comment `-- DESTRUCTIVE`, wrapped in `START TRANSACTION; ... ROLLBACK;` by default; user flips to `COMMIT`.
- Only file written: the data file. Never run the SQL or hit a DB.
- Header comment (1 line, `sql`/`csv` where allowed): what it is and for which case. JSON has none.

## File

- Root: repo root (`git rev-parse --show-toplevel`), else cwd.
- Dir `cc-data/<topic>/` in root, create if missing. Topic = logical area, kebab 1-2 words (`autopay`, `loan-schedule`). Reuse existing: `ls cc-data/`.
- Name `YYYYMMDD-N-<slug>.<ext>`. Date = `date +%Y%m%d`. N = highest N in that topic folder + 1 (any ext). Slug English kebab 2-4 words → `cc-data/autopay/20261012-2-whitelist-insert.sql`.

## Output — one line

```
cc-data/<topic>/<YYYYMMDD-N-slug>.<ext> — <what, N rows/lines>
```
