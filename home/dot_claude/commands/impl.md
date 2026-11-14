---
description: Execute a cc-plans/*.md implementation plan step by step, following code rules. Verify before done.
argument-hint: <cc-plans/.../YYYYMMDD-N-slug.md>
---

# Execute plan

Plan: $ARGUMENTS

Empty or file missing → STOP, ask one line: which plan file.

## Before code

- Read the plan file fully.
- Read project `CLAUDE.md`, `AGENTS.md` if present. Java → `~/.claude/rules/java-comments.md`. Global rules: `~/.claude/CLAUDE.md`.
- `Open questions` not `none` → STOP, list them, ask. Do not guess.
- Read every file in `Touch` before editing. Plan path/API wrong vs code → trust code, note it.

## Do

- Steps in order. Only what plan says. Out of scope stays out.
- Match surrounding code: naming, layers, patterns. Reuse first.
- Minimal code. No noise comments, no TODO, no dead code.
- Add tests from plan `Tests` section in project's test style.

## Verify

- Run project checks (Java/Quarkus: `./mvnw spotless:apply`, then `./mvnw test` for touched tests; full `./mvnw test` if shared code changed).
- Fail → fix, re-run. Still fail after 2 tries → STOP, report output.
- Plan has `Done when` → do each item (`/simplify`, `/code-review` on diff).
- No commit.

## Output

```
<plan path> — <N>/<total> steps done
Changed: <files>
Checks: <command> — pass | fail
Skipped / deviated: <list | none>
```
