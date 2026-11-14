---
description: Walk through a plan's Open questions, propose an answer for each, write the decisions back into the plan.
argument-hint: [cc-plans/.../YYYYMMDD-N-slug.md]
allowed-tools: Read, Grep, Glob, Edit, Bash(ls:*)
---

# Close open questions

Plan: $ARGUMENTS

Empty → newest file in `cc-plans/` (`ls -t cc-plans/*/*.md | head -1`). Say which one.

## Flow

1. Read plan. `Open questions` is `none` → say so, STOP.
2. Per question: read the code/config needed to ground it (Grep/Read). Pick a lean only with evidence. No evidence → write `мэдэхгүй — <юу хэрэгтэй, хэнээс>`. Never guess.
3. One message, Mongolian, numbered. Per question: question, options (A/B), `санал:` pick + one-line why, which step it blocks.
4. End: `ok` = бүх санал зөв. `2: B`, `3: <өөрийн хариу>` = тухайн асуулт. Үлдсэн нь нээлттэй хэвээр.
5. After reply, Edit the plan (caveman English):
   - Answered Q → move to `## Decisions`: `Q<N>: <answer> — <why>`. Remove from `Open questions`.
   - Remove `(blocked: Q<N>)` markers. Update `Steps`/`Touch`/`Tests`/`Data / API` the answer changes.
   - Answer opens a new question → add `Q<next>` to `Open questions`.
   - Unanswered stay as is.
6. All closed → `Open questions` = `none`. Tell: ready for `/impl <plan>`. Else list what remains.

## Rules

- Only the plan file is edited. No code.
- Never mark a question closed without a user reply.
- Keep Q numbers stable; never renumber.
