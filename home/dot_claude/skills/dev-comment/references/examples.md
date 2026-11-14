# Examples

Load for calibration. Good ones are samples of register, not templates. Don't reuse the wording.

## Good

**Jira · progress**
> Retry logic is in. Still working through the case where Keycloak returns a 5xx mid-refresh.

**Jira · completion**
> Merged !412. Lock check now runs before the token refresh, so concurrent logins can't both get through. Verified on dev.

**Jira · blocker**
> Can't test the borrower flow on test yet. The realm is missing the `user` role. Pinged infra.

**Jira · investigation (cause unconfirmed)**
> Repro'd the timeout on dev. Looks like the connection pool runs out under the batch job, but I haven't confirmed it. Checking pool metrics next.

**Jira · testing**
> Ran the attempt-guard IT against MySQL and MariaDB, both pass. Redis cluster path still untested.

**GitLab · review suggestion**
> This reads then writes the counter without a lock, so two requests can both pass the limit check. Could use `INCR` and check the result instead.

**GitLab · nit**
> nit: `findUser` is called twice here, could reuse the first result.

**GitLab · disagreement**
> I'd keep the check in the service. The resource layer doesn't know about branch scope, so we'd end up duplicating it. Happy to talk it through if you see it differently.

**GitLab · review reply (fix verified)**
> Good catch. Fixed in `a3f91c2`.

**GitLab · clarification**
> It's `REQUIRES_NEW` on purpose. The audit row has to commit even when the outer transaction rolls back.

**GitLab · question**
> Does this path ever run without the tenant header? If it can, `getTenant()` will NPE here.

**GitLab · CI failure**
> `test:integration` is failing on `MySqlAttemptGuardIT`, looks like a container startup timeout. Re-running.

**Mongolian → English**
Input: `энэ endpoint дээр lock шалгах хэрэгтэй байх, одоо шалгахгүй байгаа`
> I think we should check the lock state here. This endpoint doesn't seem to handle it yet.

**Broken English → natural**
Input: `i change the query now use index, but not test in prod yet`
> Switched the query to use the index. Haven't tested it on prod yet.

**Formal → casual**
Input: `I would like to inform you that I have completed the implementation of the retry mechanism and am now proceeding with the validation of edge cases.`
> Retry logic is in. Checking edge cases now.

**Ack**
> Will do.

## Bad (and why)

| Bad | Problem | Fix |
|---|---|---|
| "I have successfully implemented the retry mechanism and made the necessary changes to ensure seamless functionality. Feel free to reach out if you have any questions." | AI stock phrases, no detail, ritual closer | "Retry logic is in. Backoff is 200ms, 3 attempts." (only if true) |
| "Thank you so much for this valuable feedback! I have addressed your comment by updating the implementation accordingly." | Padding, says nothing | "Good catch. Fixed in `a3f91c2`." (hash must be real) |
| "lgtm tbh, lol rn it works fine imo" | Excess shorthand, unreviewed LGTM | Review the diff, then say what was checked |
| "Fixed, tested on prod, all green." (user said nothing about testing) | Invented test result and env | "Fixed." or ask what was tested |
| "Root cause was the connection pool." (user only suspects it) | Hedge dropped | "Looks like the pool, not confirmed yet." |
| "Fixed in the latest commit." (nothing pushed) | Unverified claim | Hold until pushed, or "will push shortly" |
| Five-paragraph reply to "can you rebase?" | Overlong | "Done." / "Rebasing now." |
| "You clearly didn't think about concurrency here." | Attacks the author | "Two requests can pass this check at once. Needs a lock or an atomic update." |
| "Yo, this code is kinda sus, ngl 😂" | Wrong register for a review | "This branch looks unreachable. Is it dead?" |
| "## Status Update\n**Completed:** ...\n**Next Steps:** ..." | Formal report shape | Two plain sentences |
| "Great job! Excellent work! Really impressive!" | Generic praise | Specific line or nothing |

## Variation sample (same fact, different openers)

- "Retry is in. Backoff is capped at 5s."
- "That 5xx path is handled now, backoff capped at 5s."
- "Added retries with a 5s cap on backoff."
- "Done, retries cap out at 5s."

Pick based on what the thread needs, not rotation by rote.
