---
name: dev-comment
description: Draft or rewrite Jira issue comments and GitLab MR comments (review comments, replies, fix confirmations, status updates) so they read like a US-based developer wrote them. Use when the user asks to write, reply to, rewrite, or "make natural" a Jira or GitLab/MR/issue comment, or says things like "comment that the fix is done", "reply to this discussion", "progress update on ABC-123", "Jira дээр progress update бич", "Энийг GitLab дээр comment болго". Accepts English, broken English, or Mongolian input. Drafts only; never posts without explicit approval. Not for commit messages, docs, code, or general writing.
argument-hint: "[notes, ticket key, MR/discussion link, or text to rewrite]"
---

# dev-comment

Write the comment a competent teammate would actually type. Short, specific, accurate. Draft first, post only after approval.

Input: `$ARGUMENTS` (may be empty; then use the conversation context, or ask what the comment is about).

## Flow

1. **Destination.** Jira or GitLab. Infer from the key (`ABC-123` is Jira), links (`/-/merge_requests/`), or words (MR, discussion, thread, diff = GitLab; ticket, issue, status = Jira). If it's unclear and changes the output, ask one short question.
2. **Intent.** Pick the comment type (progress, done, blocker, review suggestion, reply, disagreement, nit, CI failure, and so on). Types are in the platform references.
3. **Context.** Read only what the comment needs: the ticket, the MR/discussion/diff, the commit, or the notes the user gave. Skip repo scans when the context is already known. If a connector isn't available, work from what the user gave and don't say you looked at the ticket or MR.
4. **Draft.** Smallest comment that carries the message.
5. **Approval.** Show the draft, wait.
6. **Post** only per the rules below.

## Facts rule

Never invent: fixes, test results, deploys, approvals, root causes, commit hashes, ticket keys, or what the code does. If the comment needs a fact you don't have, ask one focused question or leave the claim out. Keep the user's uncertainty ("I think", "seems like") as uncertainty. Never write LGTM or approve unless the changes were actually reviewed.

## Voice

Native US developer, casual but precise. Short sentences, contractions, plain verbs, real technical terms. Confident only when there's evidence. No corporate tone, fake enthusiasm, forced slang, or humor.

Cut: openers that announce the comment, thanks/apology padding, "successfully", "necessary changes", "thorough investigation", "ensure", "moving forward", "feel free to reach out", "furthermore", stacked "additionally". Don't swap them for a new stock phrase. Vary openings and length; don't start every reply with "Good catch" or "Fixed".

Shorthand (FYI, WIP, IMO, AFAIK, nit, repro, config, deps, CI, MR/PR) only where a dev would really use it. Not in every comment. Skip "lol", "rn", "btw" unless the thread is already that casual. No Markdown headers or bold in comments; code in backticks, bullets only when listing several items.

Details: `references/writing-style.md`.

## Length

Match the intent. Ack: one short sentence. Fix confirmation: one or two. Progress: where it is, what's left. Clarification: the key reason or trade-off. Complex review: short paragraphs or bullets. Don't trim facts to be short; don't pad a simple ack.

## Platform notes

- **Jira**: status first (what changed, state, blocker, next). Not a formal report. Read `references/jira-comments.md` for types and the posting tool.
- **GitLab**: about the code, not the person. Say why when it isn't obvious, ask when you're unsure, mark blocker vs. optional (`nit:`, `optional:`, `FYI:`). Read `references/gitlab-comments.md` for types and the posting commands.

## Rewrites and translation

Mongolian, broken English, formal English, or rough notes in; natural English out. Keep meaning, technical terms, ticket/commit refs, hedging, and real status. Add no claims. Show the result, not an edit-by-edit explanation. Examples: `references/examples.md`.

## Output

```
**GitLab · Draft**

> comment text

```

Plain label, quoted draft, then wait. No style notes, scores, or alternatives unless asked; if asked, give 2-3 that actually differ. Several drafts: label each (`Draft 1`, `Draft 2`) so approval maps to one.

## Approval and posting

Pipeline: context, draft, approval, post.

- Never post while drafting. Auto-invoked runs draft only.
- Approval = clear "ok / yes / approve / post it" that refers to the draft just shown. Unrelated "ok", silence, or "looks fine, but..." is not approval.
- Approval covers that exact text and that exact destination. Material edit or new destination: show again, ask again.
- Several drafts: approval tracked per draft.
- Destination ambiguous: don't post.
- Post only with a write tool that exists in this session (Jira: Atlassian connector `addCommentToJiraIssue`; GitLab: `glab`). Use the exact approved text. Say "posted" only after the call succeeded; otherwise say it failed and give the text to copy.
- No write tool or no verified destination: return the approved text ready to copy.

This skill grants no tool permissions. Normal permission prompts still apply to the write call.
