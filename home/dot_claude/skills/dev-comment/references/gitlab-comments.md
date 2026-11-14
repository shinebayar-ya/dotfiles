# GitLab comments

Load when the destination is GitLab (MR, discussion, issue, inline diff note).

Principles below come from Google's code review comment guide (be kind, explain reasoning, balance direction with pointing out problems, label severity: `Nit:`, `Optional:`, `FYI:`) and GitLab's code review guidelines (be kind; ask questions, make suggestions not demands; be explicit since intent gets lost online; accept that many decisions are opinions; reply to every comment and resolve only threads you've fully addressed; keep style to automation; don't block on non-blocking suggestions).

## Principles

- Talk about the code, not the person. "This skips the lock check" not "you forgot the lock".
- Say why when it isn't obvious. One sentence is enough.
- Ask when you don't know. A real question beats a confident guess.
- Mark weight: blocker (no label, or "needs to change"), `nit:`, `optional:`, `FYI:`. Unlabeled means "this needs to change".
- Point at the problem and let the author pick the fix, unless a concrete suggestion saves time. Use a GitLab suggestion block only when asked or the fix is a small exact edit.
- Praise only when specific and earned. Skip generic praise.
- Style the linter catches isn't a review comment.
- Don't call LGTM or approve unless the diff was actually read.

## Types

| Type | Notes |
|---|---|
| MR review (summary) | Verdict first (blocking issues vs. just nits), then the few things that matter. |
| Inline review | One point per comment, tied to the line. Say what's wrong, why, optional fix. |
| Review reply (as author) | Answer the point. If you agree, say what you changed. If you disagree, give the reason. |
| Fix confirmation | "Fixed in `abc1234`." Only with a real hash or "latest push" when the push happened. |
| Technical clarification | Explain the constraint or trade-off that drove the code. |
| Design disagreement | Reason, position, offer. Don't litigate. If it drags, suggest a call and a summary after. |
| Request for changes | List the blockers only. Move optional items to a separate, labeled short list. |
| Approval note | Only after review. Say what you looked at if not obvious. |
| Follow-up discussion | Reply in the thread; don't open a new one for the same point. |
| CI failure | Name the failing job and the cause if known; otherwise "failing on X, looking" with no guessed cause. |

## Author side

- Reply to every comment. Resolve a thread only when it's fully addressed (the commenter's call in many teams; follow the user's habit).
- "Fixed" needs a pushed commit. If it isn't pushed yet, say "will push" or hold the comment.
- Pushing back is fine. Give the reason and keep it short.

## Reviewer side

- Say which comments block merge.
- Bundle nits into one comment if there are many, or mark them `nit:`.
- Use `@name` only when addressing someone specific.

## Reading context

- `glab mr view <iid> --comments` and `glab mr diff <iid>` for the MR and its discussions (add `-R group/project` when outside the repo). `glab api projects/:id/merge_requests/<iid>/discussions` for threads with ids.
- If a link was given, parse project and MR iid from it; don't guess.
- Read the diff hunk the comment refers to before replying to a code-specific point.
- No `glab` auth or no access: work from pasted text; don't claim you read the MR.

## Posting

Only after approval of the exact draft for the exact target.

- New MR note: `glab mr note <iid> -m "<text>"`
- Reply in a discussion: `glab api -X POST projects/:id/merge_requests/<iid>/discussions/<discussion_id>/notes -f body="<text>"`
- Inline diff note needs a position (file, line, SHAs); if you can't build it reliably, give the text to copy instead.
- Confirm project, MR iid, and (for replies) discussion id before the call. Don't resolve threads, approve, or merge as a side effect.
- Pass the body safely (quotes, backticks, newlines); prefer a heredoc or `-F body=@file` over interpolating into a shell string.
- Failed or unavailable: say so, return text to copy. Don't say "posted".
