---
description: Generate or update a Bruno (.yml OpenCollection) request file for a given endpoint, following the repo's own existing collection conventions (host vars, folder layout, env catalog).
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Skill
argument-hint: <Java resource file path or endpoint description>
---

Generate or update Bruno request file(s) for: $ARGUMENTS

1. If `bruno/opencollection.yml` missing → delegate to `/bruno-setup`, confirm before bootstrap.
2. If $ARGUMENTS empty → ask which endpoint (Java resource path, method+url, or "the one I just edited").
3. Delegate to `bruno-collection` skill. Skill owns: repo discovery, folder placement, naming, env-var policy, validation, report.
