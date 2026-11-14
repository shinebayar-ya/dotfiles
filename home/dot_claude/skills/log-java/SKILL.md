---
name: log-java
description: Write log lines in Quarkus (2.x / 3.x) Java services. Triggers on /log-java, "add log", "log this", "log error", or auto when editing `src/main/java/**/*.java` — REST resources, ApplicationScoped services, catch blocks, and Scheduled jobs get log lines. Default API is JBoss Logging via `@Inject Logger` (Quarkus native). SLF4J accepted when project already uses it. Style — short English sentence + key=value parameters. Five levels — debug/info/warn/error/fatal. Backend dev voice, no AI vibe, no PII.
---

## When to log (auto-trigger map)

| Code shape | Level | What to log |
|---|---|---|
| `@Path` resource method (entry to a REST endpoint) | `info` | route + key path/query params (no body) |
| `@ApplicationScoped` service method (public, side-effectful) | `info` | action start with id args |
| `catch (Exception e)` block | `error` | message, exception class, key context |
| `catch` that recovers + degrades | `warn` | reason, fallback taken |
| Domain rule rejection / validator failure | `warn` | rule id, input id |
| Unreachable / `IllegalStateException` branch | `fatal` (or `error`) | full state |
| Tight loop / dev trace | `debug` | iteration var, intermediate |
| `@Scheduled` / cron job start + end | `info` | job name, processed count |
| REST client (`@RegisterRestClient`) call | `info` on send, `error` on fail | endpoint, status, request id |
| Kafka / SQS / SmallRye Reactive Messaging consume | `info` on receive, `error` on fail | topic/queue, message id |
| Auth / JWT verify failure | `warn` | reason, no token |

Do **NOT** log:
- Inside hot loops at `info` or above.
- Trivial getters/setters, records, DTOs.
- What an interceptor (`@ServerRequestFilter`, OpenTelemetry, access log) already records.

## Inject pattern

### JBoss Logging (Quarkus default, preferred)

```java
import org.jboss.logging.Logger;
import jakarta.inject.Inject;

@ApplicationScoped
public class LoanService {

    @Inject
    Logger log;
}
```

Or static field (allowed, no DI overhead):

```java
private static final Logger log = Logger.getLogger(LoanService.class);
```

### SLF4J (only if project already uses it)

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

private static final Logger log = LoggerFactory.getLogger(LoanService.class);
```

Pick **one** logging API per project — match what's already imported. **Never** `System.out.println`. **Never** `e.printStackTrace()`.

## Message format (HARD RULE)

```java
log.<level>f("<short english sentence> key1=%s key2=%d", val1, val2);
```

- **Message** — short imperative or past-tense sentence. Lowercase start OK. No trailing period.
- **Parameters** — `key=%s` pairs after the sentence, snake_case keys, ≤6 keys. Always include an id (`loan_id`, `user_id`, `request_id`).
- **Length** — message body ≤80 chars before params.
- **Use parameterized form** — `infof`/`debugf`/etc (JBoss) or `{}` placeholders (SLF4J). **Never** `+` string concat — wastes CPU when level disabled.

### JBoss Logging — Good

```java
log.infof("loan disbursed loan_id=%s user_id=%s amount=%s",
    loan.getId(), loan.getUserId(), loan.getAmount());

log.warnf("product assign skipped, balance too low user_id=%s balance=%s min=%s",
    userId, balance, product.getMinAmount());

log.errorf(e, "iris call failed endpoint=%s status=%d request_id=%s",
    url, response.getStatus(), requestId);
```

### SLF4J — Good

```java
log.info("loan disbursed loan_id={} user_id={} amount={}",
    loan.getId(), loan.getUserId(), loan.getAmount());

log.error("iris call failed endpoint={} status={} request_id={}",
    url, response.getStatus(), requestId, e);   // last arg = throwable
```

### Bad → fix

```java
// ❌ string concat, level check skipped only by JIT, not by API
log.info("Loan " + loanId + " for user " + userId + " amount " + amount);
// ✅
log.infof("loan disbursed loan_id=%s user_id=%s amount=%s", loanId, userId, amount);

// ❌ AI vibe
log.info("Successfully processed and persisted comprehensive loan data");
// ✅
log.infof("loan saved loan_id=%s", loan.getId());

// ❌ exception swallowed, message lost
log.error("error: " + e.getMessage());
// ✅ JBoss — exception is first arg
log.errorf(e, "loan save failed loan_id=%s", loanId);
// ✅ SLF4J — exception is last arg
log.error("loan save failed loan_id={}", loanId, e);

// ❌ printStackTrace bypasses log infra entirely
} catch (Exception e) {
    e.printStackTrace();
}
// ✅
} catch (Exception e) {
    log.errorf(e, "loan save failed loan_id=%s", loanId);
    throw new LoanSaveException("loan save failed", e);
}

// ❌ log then rethrow same info — duplicate noise
} catch (Exception e) {
    log.error("failed", e);
    throw e;
}
// ✅ log OR rethrow. Rethrow → let outer handler log.
```

## Level decision tree

```
Did something go wrong?
├─ no, normal flow  ──► info  (or debug if noisy)
└─ yes
    ├─ recoverable, caller continues  ──► warn
    ├─ this request/job failed, but service alive  ──► error
    └─ data corrupt / invariant broken / oncall needed  ──► fatal
```

| Level | Use for | NOT for |
|---|---|---|
| `debug` | dev-only trace, loop bodies, intermediate values | anything prod-relevant |
| `info` | business event success, REST entry, job start/end | every method call |
| `warn` | recoverable failure, business rule reject, retry, deprecated path | unexpected exceptions |
| `error` | request/job failed, external dep down, unhandled domain error | recoverable cases |
| `fatal` | data corruption, invariant violated, paging-worthy | normal HTTP 4xx/5xx |

`trace` exists in JBoss but rarely needed — prefer `debug`. SLF4J's `trace` follows same rule.

## Level guard for expensive context

When building the log message needs a non-trivial call:

```java
// JBoss
if (log.isDebugEnabled()) {
    log.debugf("payload dump loan_id=%s json=%s", id, mapper.writeValueAsString(payload));
}

// SLF4J
if (log.isDebugEnabled()) {
    log.debug("payload dump loan_id={} json={}", id, mapper.writeValueAsString(payload));
}
```

Parameterized form already skips toString on disabled levels — the guard is only for **extra** work outside the call.

## Exception logging

- **JBoss** — exception is the **first** arg of `errorf` / `warnf` (overload).
- **SLF4J** — exception is the **last** arg (auto-detected when the placeholder count is one less than args).

Never:
- `log.error(e.getMessage())` — loses class + stack.
- `log.error("failed " + e)` — `toString()` of Throwable is class+message, no stack.
- `log.errorf("failed %s", e)` — same problem; pass `e` as the throwable arg, not a `%s` substitution.

## MDC / context propagation

For request-scoped context (trace id, user id), use `ThreadContext` (JBoss) or `MDC` (SLF4J). In Quarkus, OpenTelemetry already injects `traceId` / `spanId` — do not duplicate.

```java
import org.jboss.logging.MDC;

MDC.put("user_id", userId);
try {
    // ... work ...
} finally {
    MDC.remove("user_id");
}
```

Configure log format in `application.properties` to render MDC:

```properties
quarkus.log.console.format=%d{HH:mm:ss} %-5p [%c{2.}] (%t) %X %s%e%n
```

## REST resource entry logging

Prefer a single `@ServerRequestFilter` for uniform access logs over per-endpoint `log.info` lines. Only add an explicit log inside the resource method when:

- The endpoint has non-obvious business outcomes (`createLoan` → log the new id).
- A specific branch needs auditing (`approveLoan` → log approver id + decision).

```java
@POST
@Path("/loans")
public Response createLoan(LoanRequest req) {
    Loan loan = service.create(req);
    log.infof("loan created loan_id=%s user_id=%s amount=%s",
        loan.getId(), loan.getUserId(), loan.getAmount());
    return Response.status(201).entity(loan).build();
}
```

## Scheduled / batch jobs

```java
@Scheduled(cron = "0 0 1 * * ?")
void expireProducts() {
    log.info("product expire start");
    try {
        int count = service.expireDue();
        log.infof("product expire done expired=%d", count);
    } catch (Exception e) {
        log.errorf(e, "product expire failed");
    }
}
```

Emit start + done. Long loops — log progress every N items, not every iteration.

## Privacy / secrets (HARD)

Never log:
- Passwords, tokens, JWTs, API keys, signed URLs, refresh tokens.
- Full PAN / card number / CVV.
- National ID / register number (last 4 only if needed).
- Full request/response body of auth endpoints.
- Raw exception messages from third-party libs that may echo a secret.

Redact:

```java
log.infof("auth header present prefix=%s",
    header == null ? "null" : header.substring(0, Math.min(8, header.length())) + "...");
```

When you spot existing code logging a credential — flag to user, do not copy.

## Configuration (`application.properties`)

| Property | Use |
|---|---|
| `quarkus.log.level=INFO` | root level |
| `quarkus.log.category."com.acme.loan".level=DEBUG` | per-package override |
| `quarkus.log.console.json=true` | structured JSON output for prod |
| `quarkus.log.console.format=...` | dev human format |

For prod — JSON output. Each key=value in the message becomes a searchable field once parsed by the log pipeline.

## Checklist (run mentally)

- [ ] Logger injected via `@Inject` or `Logger.getLogger(Class)` — never `new`, never `System.out`.
- [ ] One logging API per project — JBoss XOR SLF4J, match existing imports.
- [ ] Level matches the decision tree.
- [ ] Message is short English sentence, ≤80 chars, no period.
- [ ] Parameterized form (`infof` / `{}`) — no `+` concat.
- [ ] Identifier present (`loan_id`, `user_id`, `request_id`) — line is greppable.
- [ ] Exception passed as throwable arg (JBoss first, SLF4J last) — never `%s`'d.
- [ ] No PII, no secrets, no token, no PAN.
- [ ] Not duplicated by `@ServerRequestFilter` / OpenTelemetry.
- [ ] `info`+ logs are not inside a tight loop.
- [ ] No log-and-rethrow pair.
- [ ] Expensive context wrapped in `isDebugEnabled()` guard.

## Anti-patterns

- ❌ `System.out.println`, `System.err.println`, `e.printStackTrace()`.
- ❌ `Logger log = new Logger(...)` — use `getLogger(Class)` or `@Inject`.
- ❌ String concat in message — `"failed " + id`.
- ❌ Trailing period / exclamation in message.
- ❌ `log.error(e.getMessage())` — loses stack.
- ❌ `log.errorf("x %s", e)` — pass `e` as throwable arg, not substitution.
- ❌ Logging full request body / headers / cookies without redaction.
- ❌ `info` for an exception. `error` for a normal HTTP 200.
- ❌ Logging then immediately rethrowing the same exception.
- ❌ Mixing JBoss + SLF4J imports in the same module.
- ❌ AI vibe: `comprehensive`, `successfully`, `robust validation`, `leverage`, `seamless`. Use simple verbs.
- ❌ CamelCase / PascalCase keys (`userId=`, `LoanID=`) — use `user_id=`, `loan_id=` so JSON ingest matches PHP service.
