---
name: ui-feature
description: Full UI/UX expert review → plan → implementation pipeline for any component or feature
tools: Read, Write, Edit, Bash, Glob
---

## UI Feature Pipeline

You are orchestrating a 4-phase UI development workflow for: **$ARGUMENTS**

### PHASE 1: UX Expert Review
Spawn the `ux-critic` subagent with this task:
"Review and create a UX plan for: $ARGUMENTS. Read any existing related components first."

Wait for ux-plan.md to be created.

### PHASE 2: Component Planning  
Spawn the `ui-planner` subagent:
"Read ux-plan.md and create component-plan.md"

Wait for component-plan.md.

### PHASE 3: Show Plans & Get Approval
Display a summary of both plans to the user.
Ask: "Shall I proceed with implementation? Any changes needed?"
STOP AND WAIT for user confirmation.

### PHASE 4: Implementation
Only after approval:
- Follow component-plan.md exactly
- Implement mobile-first (375px base)
- Add all states mentioned in ux-plan.md
- Run: npx tsc --noEmit to check types
- Run existing tests

Report: "✅ Done. Run /mobile-check http://localhost:3000/[path] to verify"
