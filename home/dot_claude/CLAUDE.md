# Global Code Style

Applies to all code I write, every language, every project. Project-level CLAUDE.md overrides this on conflict.

## Core principle: minimal code

Write the least code that solves the problem. Fewer lines, fewer branches, fewer layers. Delete before you add. If a function fits in 5 lines, don't write 20. No speculative generality — build for the case in front of you, not imagined future ones (YAGNI).

## Naming

- Basic English. Common application-development words (`user`, `count`, `items`, `total`, `find`, `save`, `send`, `parse`, `valid`). No rare or invented words.
- Short. Prefer the shortest name that stays clear: `user` not `applicationUserEntity`, `id` not `identifier`, `count` not `numberOfElements`.
- No type/role suffixes when context is obvious: `users` not `userList`, `repo` not `userRepositoryService`.
- Follow each language's casing convention (PHP/Java/JS method+var camelCase, class PascalCase, Python snake_case, constants UPPER_SNAKE).
- Loop/short-scope vars can be 1 letter (`i`, `e`, `f`). Boolean reads as a question: `isActive`, `hasAccess`, `canEdit`.
- Match names already used in the surrounding file/module over my own preference.

## Comments

- Short title/group comments allowed (e.g. `# Themes`, `# Aliases`) when the file already uses that pattern.
- No comment that restates the code (`// increment i`, `// loop over users`).
- No docblocks just to have them. No `@param`/`@return` that only echo the signature.
- No commented-out code. Delete it; git remembers.
- No TODO/FIXME unless I'm explicitly asked to leave one.

## Verify after finishing

- After any change, always verify with whatever the project offers: config validators (`ghostty +validate-config`), linters, type checks, tests, build. Run it before reporting done.

## No AI-vibe code

Write like a working developer under deadline, not like a tutorial or a framework demo. Avoid:

**Structure / over-engineering**
- Over-abstraction: interfaces, factories, strategies, wrappers with one implementation. Don't add a layer until a second caller needs it.
- God methods / god classes: split when a method does several unrelated things. But don't shred into 10 one-line helpers either — balance.
- Premature generalization: config flags, plugin hooks, "extensible" scaffolding nobody asked for.
- Needless indirection: pass-through methods, managers that only delegate, services wrapping a single function call.
- Re-implementing what the stdlib/framework already gives (hand-rolled date math, manual array loops where a built-in fits).

**Validation / defensiveness**
- Over-validation: re-checking the same precondition at every layer, guarding inputs that can't occur given the call site.
- Defensive null checks on values the type system or framework guarantees.
- Try/catch that catches, logs, and rethrows with no added value, or swallows errors to look "safe".
- Validating then immediately using — trust the boundary that already validated.

**Verbosity / ceremony**
- Intermediate variables used exactly once where inlining is clearer.
- Verbose ternaries/if-else where an early return or guard clause is shorter.
- Re-wrapping return values in new objects/DTOs when the existing one fits.
- Logging every step. Log at boundaries and on real errors, not narration.

**Vocabulary** (in code, identifiers, log/error strings, and commit/PR text)
- Drop: `comprehensive`, `robust`, `seamless`, `leverage`, `facilitate`, `utilize` (use `use`), `streamline`, `enhance`, `establish`, `ensure that`, `in order to` (use `to`), `delve`, `intricate`, `holistic`, `cutting-edge`, `state-of-the-art`, `best-in-class`, `powerful`, `flexible`, `elegant`, `simply`, `effortless`, `unleash`, `empower`, `boilerplate`-style filler.
- Plain verbs: `add`, `fix`, `remove`, `update`, `get`, `set`, `make`, `use`, `call`, `read`, `write`.

## Tests

- New public method, class, endpoint, or bug fix → add a test in the project's existing test setup and style.
- Match the project's framework, directory layout, and naming (don't introduce a new test lib).
- Test behavior and edge cases, not the obvious happy path only. One assert per concept.
- No over-mocking: mock the boundary (network, clock, external service), use real objects for the rest.
- Keep test code to the same minimal standard — no helper frameworks for two tests.

## When unsure

Match the surrounding code over these rules. Consistency inside a file beats global preference.

## Code Style & Comments
- Follow Java commenting standards in `~/.claude/rules/java-comments.md`.
- Never write self-descriptive noise comments; keep only 1-line "WHY" or schema comments.

## Claude-generated files (cc-*)
Put them in repo-root `cc-<type>/<topic>/YYYYMMDD-N-slug.<ext>` (N = next number among same-date files in that topic folder, first of the day = 1; non-md keeps its extension). Never the repo root itself, never `scratch/`, `_*.sh`. Gitignored via `cc-*`.
- `cc-plans` implementation plans (`/iplan`)
- `cc-docs` living reference: design, cron, deploy, status codes (`/wiki`)
- `cc-reports` point-in-time findings: review, audit, debug (`/sniff`)
- `cc-notes` explanations (`/what`)
- `cc-tasks` TODO / checklists (`/todo`)
- `cc-data` sample data, scripts, one-off `.sql`, json (`/kit`)
Reuse an existing topic folder (`ls cc-<type>/`). Moving files: fix cross-refs.
