---
description: Strip noise comments from Java/Quarkus code efficiently.
allowed-tools: Read, Edit, Bash, Glob, Grep
argument-hint: [file/glob | empty = git changed files]
---

Clean comment noise in Java/Quarkus source files. Keep ONLY non-obvious "WHY" logic and complex field structures.

## Scope
1. Direct target files via `$ARGUMENTS` if present.
2. Otherwise target modified files: `git diff --name-only HEAD` & `git diff --cached --name-only`. Skip generated/build dirs (`target/`, `.build/`).

## Rules

### DELETE (Noise & AI Vibe)
- Verbose Javadocs that re-state field names or type declarations (`/** The ID of the user */`).
- Boilerplate block docs (`/** @author ... */`, empty `@param`, `@return`).
- Self-explanatory inline comments (`// getter`, `// constructor`).
- Commented-out dead code, section banners (`// --- fields ---`).

### KEEP & REWRITE (Human-Readable & Short)
Keep a comment ONLY for:
1. **Schemaless / JSONB fields (`customData`, `metadata`):** Summarize expected structure/keys in 1 line (`// jsonb keys: { providerId, rawPayload }`).
2. **Uncommon / Business-specific fields:** Write 1 line explaining the "WHY" behind the field (`// bypasses 2FA for legacy clients`).
3. **Non-obvious logic / workarounds:** 1 line, lowercase, simple English (`// retry needed due to legacy gateway timeout`).

*Style constraint:* Max 1 line of content per comment. Never use corporate AI phrasing like "This method is responsible for...".

*Entity field format:* On entity fields (any field directly under a class annotated `@Entity`, `@Embeddable`, or `@MappedSuperclass`), write the kept line as a Javadoc block, not `//`:
```java
/** jsonb keys: { providerId, rawPayload } */
@Column(name = "custom_data")
private String customData;
```
Place the block immediately above the field, above any annotations that sit between it and the `private`/`protected`/`public` declaration — annotations stay directly attached to the field, the Javadoc goes above all of them. Non-entity fields (locals, DTOs, params) keep the `//` form.

*Parsing existing Javadoc:* When a field already carries a `/** ... */` block, strip the opening `/**`, the closing `*/`, and each line's leading `*` before judging it under DELETE/KEEP — a verbose block that only restates the field name or type is deleted like any other noise comment. A block worth keeping is reformatted into the single-line form above; multi-line Javadoc collapses to one line unless the field is part of a public API export, in which case keep the multi-line block but strip restated `@param`/`@return`-style noise from it.

### NEVER TOUCH
- Quarkus/CDI/JAX-RS/Jackson/Hibernate annotations (`@Inject`, `@ConfigProperty`, `@Path`, `@Column`, `@Entity`, `@JsonProperty`, etc.).
- Tooling/Compiler directives (`@SuppressWarnings`, `@Override`).
- License headers and copyright blocks.

## Execution & Output Efficiency
1. Read target files, apply removals/rewrites via `Edit`. Preserve logic and spacing.
2. Output ONLY a final summary: "Processed [X] files: [Y] comments removed, [Z] comments rewritten."
