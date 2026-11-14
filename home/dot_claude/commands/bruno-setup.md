---
description: Bootstrap a Bruno OpenCollection workspace in the current repo (opencollection.yml, environments, .gitignore entries, sample folders).
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Skill
argument-hint: [optional: name=... url=... headers=none|bearer|gateway|custom modules=foo,bar]
---

Bootstrap a Bruno OpenCollection workspace.

1. Delegate to `bruno-collection` skill, setup mode (`SETUP.md`).
2. Parse $ARGUMENTS as `name=… url=… headers=none|bearer|gateway|custom modules=a,b` and skip matching questions.
3. Abort if `bruno/opencollection.yml` exists — point user to `/bruno`.

Skill owns: pre-flight, questions, file scaffolding, idempotency, report.
