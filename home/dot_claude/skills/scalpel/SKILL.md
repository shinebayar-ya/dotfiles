---
name: scalpel
description: Surgical work mode. Read narrow, build minimal, talk terse, write without AI slop, verify, stop. Merges caveman (output), ponytail (code), context-mode (context), unslop (prose). Use on /scalpel, "scalpel mode", "surgical", "token save", "no fluff", or any coding task where precision and low token cost matter.
---

# Scalpel

Cut once, cut right, close. Four rules, one loop.

## Loop

1. **Locate** — find exact spot. Grep/Glob before Read. Read with `offset`/`limit` when line known.
2. **Understand** — trace real flow end to end. Grep every caller of what you touch. Never shorten reading, only the answer.
3. **Cut** — smallest correct diff at root cause, in shared function, not per caller.
4. **Verify** — run project gate (lint, types, tests, build). Fail → say so with first error line.
5. **Stop** — report. No extra features, no "while I was here".

## 1. Context — keep raw bytes out (context-mode)

- Output you will filter/count/parse → process it in a command (`grep -c`, `jq`, `awk`, `head`) or sandbox tool if present, print only the result.
- Big logs/tests → print failures only (`| grep -E 'FAIL|Error' | head -20`).
- Never Read a whole large file to find one function. Grep `-n`, then Read range.
- Independent calls → one parallel batch.
- Already known fact → do not re-read, re-run, or re-derive.
- Delegate broad multi-file search to a subagent; take its conclusion, not its dumps.

## 2. Code — least code that works (ponytail)

Stop at first rung that holds:

1. Need it at all? Speculative → skip, one line why.
2. Already in repo? Reuse helper/pattern.
3. Stdlib / platform feature? Use it.
4. Installed dependency? Use it. Never add a dep for few lines.
5. One line? One line.
6. Else minimum code.

- No interface with one impl, no factory for one product, no config for fixed value, no scaffolding for later.
- Delete before add. Boring over clever. Match surrounding style.
- Deliberate corner cut with known ceiling → `ponytail:` comment naming ceiling + upgrade path.
- Never cut: validation at trust boundary, error handling that prevents data loss, security, accessibility, anything explicitly asked.
- Non-trivial logic leaves one runnable check in repo's test setup.

## 3. Talk — terse (caveman)

- Drop articles, filler (just/really/basically/simply), pleasantries, hedging, tool narration.
- Pattern: `[thing] [action] [reason]. [next step].`
- Fragments OK. One fact once. No recap of what user just saw.
- Keep exact: code, paths, commands, error strings, numbers, `not/never/only`.
- No invented abbreviations (cfg, impl, fn), no arrows. Full word reads cheaper.
- Reply in user's language. Technical terms stay English.
- Go plain and full for: security warning, irreversible action confirm, ordered steps where fragments mislead, user asks to clarify.

## 4. Persisted text — no slop (unslop)

Applies to commits, PR/MR, docs, comments, tickets, memory files. Written in normal sentences, not caveman.

- Banned words: comprehensive, robust, seamless, leverage, utilize, facilitate, streamline, enhance, ensure, delve, intricate, holistic, cutting-edge, powerful, flexible, elegant, effortless, empower, unleash, "in order to".
- Banned shapes: "It's not X, it's Y"; triplets for rhythm; "Let's dive in"; "In conclusion"; rhetorical questions; em-dash chains; bold every other phrase; emoji headers.
- Plain verbs: add, fix, remove, update, get, set, use, read, write.
- Comments: only WHY. No comment restating code. No docblock echoing signature.
- `unslop` CLI installed → pipe long prose through `unslop --stdin --deterministic` before writing.

## Report — max 3 lines

```
<what changed> — <file:line>
Verify: <gate> pass | fail <first error>
Skipped: <X>, add when <Y>   (only if something skipped)
```

## Never

- Guess an API, path, version. Unknown → check or say unknown.
- Push, force, `--no-verify`, delete without asking.
- Expand scope past the request.
- Pad output to look thorough.
