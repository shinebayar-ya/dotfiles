# Jira comments

Load when the destination is Jira.

Source notes: Atlassian's comment docs pages weren't reachable when this skill was written (404 or only index content), so nothing below is quoted from them. The Jira-specific points are common practice plus the connector's behavior; verify against your Jira setup.

## Shape

Order by what the reader needs: what changed, current state, blocker, what's left, next action. Include only the parts that apply. A comment is a message to teammates, not a status report. Readers skim on a board or in a notification, so the first line should carry the point.

## Types

| Type | What to include | Typical length |
|---|---|---|
| Progress | What's done, what's left | 1-2 sentences |
| Completion | What shipped or merged, where to verify (MR, env) if known | 1-2 sentences |
| Blocker | What's blocked, on whom/what, what unblocks it | 1-3 sentences |
| Clarification | The question, with the option(s) you see | 1-3 sentences |
| Bug investigation | Repro status, cause (or "not found yet"), next step | short paragraph or 2-3 bullets |
| Testing status | What was tested, where, result, what's untested | 1-3 sentences |
| Next steps | Next action and rough order | 1-2 sentences |
| Dependency | What this waits on or what waits on this | 1-2 sentences |

## Rules

- Link by key (`ABC-123`) and MR reference (`!42`) only when the user gave them or they were read from the ticket. Never guess a key or number.
- Say "tested" only for what the user said was tested. Say where (local, dev, test) if given.
- Mention people with `@name` only when the user asks or the name is known. Mention only when the person must act.
- Root cause: state only if confirmed. Otherwise "suspect", "looks like", "not confirmed yet".
- Blockers name an owner or dependency. "Blocked" alone helps nobody.
- Don't restate the ticket title or description.
- Plain text. Jira renders wiki markup or Markdown depending on the editor/connector, so avoid headers and heavy formatting. Backticks and short bullets are enough.

## Reading context

- Connector available (Atlassian Rovo): `getJiraIssue` for the issue, comments included. Read before drafting a reply or update so the comment doesn't repeat what's there.
- No connector: use what the user pasted. Don't claim the ticket was read.

## Posting

- Tool: `addCommentToJiraIssue` (Atlassian Rovo connector), only after approval of the exact draft for the exact issue key.
- Confirm the issue key before the call; if the user said "this ticket" and there's no key in context, ask.
- Don't also transition the issue or log work unless asked separately.
- If the tool is missing or the call fails, say so and return the text to copy. Don't say "posted".
