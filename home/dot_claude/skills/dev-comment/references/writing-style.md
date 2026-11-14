# Writing style

Load when drafting needs more than the SKILL.md rules (tone calls, rewrites, edge cases).

## What "natural" looks like

- Says the thing, stops. A comment is done when the reader can act or move on.
- Names the specific: the method, the endpoint, the table, the error, the ticket. "Retry logic is in" beats "the implementation is complete".
- Past tense for what happened, present for what is true now, "I'll" or "going to" for what's next. No passive padding.
- Hedges where the writer is unsure, one hedge per claim. "I think this is a race" not "it might possibly potentially be".
- Plain connectors: "so", "but", "because". Not "therefore", "however", "furthermore".

## Recognizable AI patterns (drop on sight)

| Pattern | Why it reads fake | Instead |
|---|---|---|
| "I have successfully implemented..." | Reports effort, not result | "X is in." / "Added X." |
| "I would like to provide an update..." | Announces instead of updating | Give the update |
| "It is important to note that..." | Filler before the point | Just say it |
| "Please be informed..." | Notice-board tone | Drop |
| "After conducting a thorough investigation..." | Pads, claims rigor | "Traced it to X." |
| "I have made the necessary changes" | Says nothing | Name the change |
| "This should ensure seamless..." | Marketing | State the behavior |
| "Feel free to reach out" | Ritual closer | Drop |
| "Moving forward" | Corporate | "Next:" or drop |
| Thanks + restate + apology triple | Padding | One of them, if any |
| Matched bullet triplets, tidy "pros/cons" | Template shape | Prose, uneven is fine |
| Em dash in every other sentence | Common tell | Period or comma |

Don't replace a banned phrase with a new fixed stock phrase. If "Good catch." shows up in every reply, it's now the tell.

## Variation

Rotate how a comment opens: the result ("Retry is in."), the cause ("That NPE is from..."), the answer ("Yeah, it's intentional."), or no opener at all. Let length follow content. A two-word reply is fine when two words do the job.

## Tone by situation

- **Agreeing**: say what you'll do. "Makes sense, switching to `SELECT ... FOR UPDATE`."
- **Disagreeing**: reason first, then position, then offer. "I'd keep the lock here. Without it two refreshes can race and both write. Open to moving it into the repo if you'd rather."
- **Unsure**: ask a real question. "Does this path ever run without a tenant header?"
- **Blocking someone**: plain, no apology theater. "Can't test this until the Keycloak realm has the role. Waiting on infra."
- **Praise**: only if specific and earned, one line. Skip generic praise.
- **Pushing back on a nit**: short. "Leaving as is, matches the other resources."

## Shorthand rules

Fine: FYI, WIP, LGTM (only after real review), IMO, AFAIK, nit, repro, config, deps, CI, MR/PR, ack.
Avoid unless the thread already uses them: lol, rn, btw, tbh, imo-spam, emoji walls.
One or two per comment at most. If a reader outside the team might trip on it, spell it out.

## Rewriting

Keep: meaning, hedges, technical terms, keys, hashes, real status.
Change: structure, register, filler, word choice.
Never: upgrade "I think X" to "X", turn "should work" into "works", or add a cause, test, or fix the source didn't state.
Keep technical terms in English as engineers say them (endpoint, lock, retry, token, migration). Don't translate them.
Mongolian input: read intent and hedging (`байх`, `шиг`, `магадгүй` = uncertain) and carry it into English.

## Quick self-check before showing a draft

1. Every factual claim comes from the user, the ticket/MR, or the code I read?
2. Could I cut a sentence without losing anything?
3. Does it open like the last three comments did?
4. Any phrase from the table above?
5. Would a teammate say this out loud?
