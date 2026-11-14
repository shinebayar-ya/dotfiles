---
description: Explain code, concept, or error in short Mongolian. Save to cc-notes/<topic>/YYYYMMDD-N-<slug>.md.
argument-hint: <concept | file:line | symbol | error>
allowed-tools: Read, Grep, Glob, Write, Bash(ls:*), Bash(date:*), Bash(git rev-parse:*), Bash(pwd)
---

# What

Topic: $ARGUMENTS

## Input

- File path, `file:line`, symbol → read that code first, explain the real code, not generic theory.
- Error text → explain cause and fix.
- Concept → explain concept, example in repo's language if repo has one.
- Empty → use what we were just talking about. Nothing there → ask one line: what to explain.

## Language

- Mongolian prose.
- Technical terms stay English as devs say them: middleware, closure, hydration, dependency injection, race condition, promise, hook, commit, rebase. Never invent Mongolian translation for them.
- Code, identifiers, commands, error strings: unchanged.

## Style

Caveman + unslop. Start with the point. No intro ("Сайн байна уу", "Энэ бол сонирхолтой асуулт"), no closing summary, no "товчхондоо", no filler. Short sentences. Plain words. One idea per bullet. No emoji.

## Structure

```markdown
# <Topic>

**Нэг өгүүлбэрээр:** <what it is, plain>

## Яаж ажилладаг
- <mechanism, 3-6 bullets>

## Жишээ
<smallest real snippet that shows it, 5-20 lines, comments in Mongolian only where non-obvious>
<one line: what the snippet prints/does>

## Анхаарах
- <common mistake / gotcha, 1-3 bullets>

## Хэзээ хэрэглэх
- <when yes / when no, 1-3 bullets>
```

Sections with nothing real to say → drop them. Never pad. Example section is required.

## Save

- Root: repo root of the explained file (`git -C <dir> rev-parse --show-toplevel`), else cwd.
- Dir `cc-notes/<topic>/` in root, create if missing. Topic = logical area, kebab 1-2 words (`php`, `doctrine`, `autopay`). Reuse existing topic folder if one fits: `ls cc-notes/`.
- Existing: Glob `cc-notes/<topic>/*.md` in root.
- Name: `YYYYMMDD-N-<slug>.md`. Date = today. N = next number in that topic folder. Slug English kebab 2-4 words → `cc-notes/php/20261012-1-closure-explained.md`.
- Same topic already saved → overwrite that file instead of new number.

## Output

Print the explanation in chat, then last line:

```
saved: cc-notes/<topic>/<YYYYMMDD-N-slug>.md
```
