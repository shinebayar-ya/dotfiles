---
description: Angular Conventional Commit via git-commit skill. Single line only, no scope, no body, no approval prompt. Basic English, common dev words. No AI co-author. No AI-vibe phrasing.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Skill, AskUserQuestion
argument-hint: ["free-text hint" | --amend | --no-verify]
---

Run `git-commit` skill.

1. Delegate to `git-commit` skill. Skill owns: pre-flight, commitlint detect, draft, sanitize (strip scope, strip body, strip AI markers, fix AI-vibe), validate, execute, hook recovery.
2. Pass `$ARGUMENTS` as hints — free-text hint, or `--amend` / `--no-verify` (warn once when honored).
3. **Single line only.** `<type>: <subject>`. No scope. No body. No footer. No confirmation prompt — commit directly after sanitize + validate.
4. Never inject `Co-Authored-By: Claude` or any AI marker. Never use AI-vibe vocab (`comprehensive`, `leverage`, `facilitate`, `robust`, `seamless`, `streamline`).
5. **Basic English, common dev words only** — plain verbs (`add`, `fix`, `close`, `split`, `wire`, `gate`). No rare, academic, or invented words.
6. **Triggers:** `/commit`, "commit", "commit this", "make a commit".
