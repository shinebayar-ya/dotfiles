---
description: Apply strict work rules (surgical edit, YAGNI, diagnose first, 3-try budget, red-team review) to the task.
argument-hint: [task]
disable-model-invocation: true
---

# Guard

Follow these rules for the task below and for the rest of this session.

1. Surgical editing: edit only the exact lines needed. Do not refactor, rename, or restyle working code around them.
2. Strict YAGNI: write the simplest code that works. No speculative features, abstraction layers, or over-engineering.
3. Diagnose first: do not guess fixes. Prove the root cause with a minimal failing test or a diagnostic log before editing production code.
4. Iteration budget: at most 3 attempts to fix any error. After 3 failures in a row, stop, revert your changes, and ask me.
5. Red-team: when asked to review code, audit for memory leaks, edge cases, security risks, and performance bottlenecks.

Task: $ARGUMENTS
