---
paths:
  - "**/*.java"
---

# Java Commenting Standard

When writing, editing, or refactoring Java code, enforce generation-time comment discipline:

- FORBIDDEN: Noise comments restating code names, getters/setters, or types (e.g., `/** User ID */`, `// constructor`).
- FORBIDDEN: Boilerplate docs (`@author`, empty `@param`, `@return`), banners, or dead code.
- ALLOWED (Max 1 line): Explain "WHY" behind business logic, workarounds, or JSONB field schemas.
- ENTITY FIELDS (`@Entity`, `@Embeddable`, `@MappedSuperclass`): Place `/** comment */` block immediately ABOVE all field annotations.
- NON-ENTITY CODE: Use standard single-line `//` form.
