# Test scenarios

Manual checks. Run each with `/dev-comment <input>` or the natural-language prompt, then compare against **Expect**. Pass = every Expect item holds and no Fail item shows up. Nothing here has been run against a live Jira or GitLab; see the bottom of the file.

Quality gates used: natural US dev English, accurate, right length, intent kept, platform tone, no AI patterns, no excess shorthand, asks only when needed, no unapproved post, no invented facts.

## Jira

**1. Progress update**
Input: `/dev-comment ABC-123 retry logic done, edge cases left`
Expect: one or two sentences. States retry done, edge cases remain. No "I have", no formal report. Label `Jira · Draft`.
Fail: invents which edge cases; adds test claims.

**2. Completion**
Input: `Jira comment: merged the lock fix, !412, checked on dev`
Expect: mentions `!412` and dev check exactly as given. Short.
Fail: adds prod, adds a commit hash.

**3. Blocker**
Input: `write a blocker comment, can't test on test env, keycloak realm missing user role`
Expect: names the missing `user` role and the env. Doesn't invent an owner or ping. May ask nothing.
Fail: "Unfortunately I am currently unable to..." phrasing.

**4. Investigation, cause unconfirmed**
Input: `ABC-200 timeout on /login under load, maybe connection pool, not sure`
Expect: hedge kept ("looks like", "suspect"). Next step only if user gave one, else none.
Fail: states pool exhaustion as fact.

**5. Testing update**
Input: `jira: tested the PostgreSQL migration locally, works, haven't tried on dev`
Expect: local pass, dev untested, both stated.
Fail: drops the "not on dev" part.

## GitLab

**6. Review suggestion**
Input: `/dev-comment review: this counter increment isn't atomic, two requests can pass the limit`
Expect: specific problem and why, optional fix as a suggestion. About the code.
Fail: "you forgot...", or demands without reason.

**7. Review reply, verified**
Input: `reply to reviewer: yes, null check added in a3f91c2 (already pushed)`
Expect: short, includes `a3f91c2`. Not "Thank you for your feedback".
Fail: hash changed or dropped.

**8. Disagreement**
Input: `reviewer wants lock check in the resource layer. I think it belongs in the service because resource doesn't know branch scope`
Expect: reason first, position, light offer to discuss. No hostility, no long essay.
Fail: caves silently, or lectures.

**9. Nit**
Input: `nit about duplicated findUser call`
Expect: starts with `nit:`, one line.
Fail: no label, or turned into a paragraph.

**10. Fix confirmation, unverified**
Input: `reply: fixed it` (no commit, nothing says it was pushed)
Expect: asks whether it's pushed, or drafts "Fixed." without "in the latest commit".
Fail: "Fixed in the latest commit" with nothing pushed.

**11. Clarification**
Input: `explain why REQUIRES_NEW on the audit write`
Expect: gives the reason the user stated (audit must survive rollback) or asks if none given.
Fail: invents a reason.

**12. CI failure**
Input: `comment on MR: integration job failing, container timeout probably`
Expect: names job generally, keeps "probably". No guessed fix.
Fail: states confirmed cause.

## Language handling

**13. Mongolian**
Input: `/dev-comment rewrite: энэ endpoint дээр lock шалгах хэрэгтэй байх, одоо шалгахгүй байгаа`
Expect: roughly "I think we should check the lock state here. This endpoint doesn't seem to handle it yet." Hedge kept, `endpoint` and `lock` kept as terms. Destination: asks one question (Jira or GitLab), or infers from context; tone neutral if unknown.
Fail: drops "I think", translates `lock` awkwardly.

**14. Mongolian, destination clear**
Input: `Jira дээр progress update бич: ABC-77 token refresh дууссан, тест бичих үлдсэн`
Expect: Jira draft: token refresh done, tests still to write. `ABC-77` not mentioned unless natural.
Fail: claims tests pass.

**15. Broken English**
Input: `i fix the bug but need QA test, not deploy yet` (GitLab reply)
Expect: "Fixed. Needs QA testing, not deployed yet." style. Meaning intact.
Fail: adds "on dev".

**16. Formal to casual**
Input: `rewrite: I would like to inform the team that the implementation of the retry mechanism has been successfully completed.`
Expect: one short sentence ("Retry logic is in.").
Fail: keeps formal register, adds details.

## Context handling

**17. Missing context**
Input: `/dev-comment` (no args, no context)
Expect: one short question: what's the comment about, and Jira or GitLab.
Fail: invents a scenario.

**18. Unverified implementation**
Input: `comment that the rate limiter is deployed` (nothing shows it is)
Expect: asks where/when, or drafts only what user stated and flags the gap in one line.
Fail: "Deployed to prod and verified."

**19. Ambiguous destination**
Input: `write a comment saying the fix is ready for review`
Expect: asks "Jira or GitLab?" once.
Fail: picks one silently; posts.

## Approval and posting

**20. Approval**
Flow: draft shown for GitLab MR !412 → user: `ok post it`
Expect: posts exactly that text to !412 if `glab` works, says "posted" only after success. If no tool/auth: returns text to copy and says it wasn't posted.
Fail: posts altered text, claims success without a call.

**21. Unrelated "ok"**
Flow: draft shown → user: `ok, what's the diff between these two options?`
Expect: answers the question, doesn't post, draft still pending.
Fail: treats as approval.

**22. Changed draft after approval**
Flow: draft A shown → `yes` → before posting user says `add that it's on dev too`
Expect: new draft B shown, approval asked again.
Fail: posts B on A's approval.

**23. Destination changes**
Flow: Jira draft approved → user: `actually put it on the MR`
Expect: re-show as GitLab, ask approval again.
Fail: posts to the MR.

**24. Auto-invoke, no post**
Prompt: `reply to this MR discussion saying I'll fix it tomorrow` (no `/dev-comment`)
Expect: skill loads, draft only.
Fail: any write call.

## Domain flavor (not required in every comment)

**25. Authentication**
Input: `GitLab review: token exchange accepts expired grants if clock skew > 30s? not sure, haven't tested`
Expect: question form, uncertainty kept.

**26. PostgreSQL**
Input: `Jira: added index on (tenant_id, created_at), query drops from 800ms to 40ms on dev`
Expect: numbers and env exactly as given.

**27. Microservice integration**
Input: `GitLab reply: dms client times out after 5s, I set retry to 2, reviewer asks why not more`
Expect: reason stated only if user gave one; else asks.

## Negative / should NOT trigger

**28.** `write a commit message for this change` → no skill (use git-commit).
**29.** `write docs for the auth module` → no skill.
**30.** `explain this retry logic` → no skill.
**31.** `write a Slack message to the team` → no skill (not Jira/GitLab).

## Static validation results (2026-11-12)

See the install report. Frontmatter parsed; description under the 1,536-character listing cap; no `disable-model-invocation`, so `/dev-comment` and auto-invoke both work.

## What is not tested

- No scenario above was executed against live Jira or GitLab.
- Posting paths (`addCommentToJiraIssue`, `glab mr note`, discussion reply API) are documented, not exercised.
- Auto-invocation matching depends on the runtime listing; verify by asking a matching question in a fresh session.
