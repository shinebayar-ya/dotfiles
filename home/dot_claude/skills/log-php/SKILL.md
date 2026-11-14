---
name: log-php
description: Write Monolog log lines in Symfony (4.4+ / 5.x / 6.x / 7.x) PHP services. Triggers on /log-php, "add log", "log this", "log error", or auto when editing controllers/services/handlers under `src/**/*.php` — new public methods, catch blocks, and request entry points get log lines. Style — short English sentence + PSR-3 context array. Five levels — debug/info/warning/error/critical. Backend dev voice, no AI vibe, no PII.
---

## When to log (auto-trigger map)

| Code shape | Level | What to log |
|---|---|---|
| Controller method (entry to `/api`, `/internal`, `/service`) | `info` | route hit, key request params (no body) |
| Service method (public, side-effectful) | `info` | action start with id args |
| `catch (\Throwable $e)` block | `error` | message, exception class, key context |
| `catch` that swallows + degrades (fallback path) | `warning` | reason, fallback taken |
| Domain rule rejection (validator throws / returns false) | `warning` | rule id, input id |
| Unreachable / "should never happen" branch | `critical` | full state dump (no PII) |
| Loop body, tight code path, dev trace | `debug` | iteration var, intermediate state |
| Cron command (`src/Command/Loan/*`) start + end | `info` | command name, processed count |
| External HTTP call (Iris, Asc, Plus, Scoring) | `info` on send, `error` on fail | endpoint, status, request id |
| DB write batch / migration step | `info` | table, row count |
| Auth/JWT decode failure | `warning` | reason, no token |

Do **NOT** log:
- Inside hot loops if level enabled in prod (use `debug`, off in prod).
- Private getters, constructors, simple DTOs.
- Code already wrapped by a logging middleware / event subscriber.

## Inject pattern

PSR-3 only. Autowired by Symfony.

```php
use Psr\Log\LoggerInterface;

final class LoanRepaidService
{
    private LoggerInterface $logger;

    public function __construct(LoggerInterface $logger)
    {
        $this->logger = $logger;
    }
}
```

PHP 8+ constructor promotion:

```php
public function __construct(
    private LoggerInterface $logger,
) {}
```

**Never** `new Logger(...)` inline. **Never** `error_log()`. **Never** `var_dump`/`print_r` left in.

For a named channel (e.g. `iris`): typehint `LoggerInterface $irisLogger` — Symfony resolves by argument name when `monolog.yaml` declares `channels: [iris]`.

## Message format (HARD RULE)

```php
$this->logger-><level>('<short english sentence>', ['<key>' => $val, ...]);
```

- **Message** — short imperative or past-tense sentence. Lowercase start OK. No trailing period. No interpolation (`"user $id failed"`) — put the id in the context array instead.
- **Context array** — flat assoc array, snake_case keys, scalar or json-encodable values. Always include identifiers that let oncall grep one line.
- **Length** — message ≤80 chars. Context — keep keys ≤6. If you need more, the log is doing two jobs — split it.

### Good

```php
$this->logger->info('loan disbursed', [
    'loan_id'   => $loan->getId(),
    'user_id'   => $loan->getUserId(),
    'amount'    => $loan->getAmount(),
    'product'   => $product->getCode(),
]);

$this->logger->warning('product assign skipped, balance too low', [
    'user_id'  => $userId,
    'balance'  => $balance,
    'min'      => $product->getMinAmount(),
]);

$this->logger->error('iris call failed', [
    'endpoint' => $url,
    'status'   => $response->getStatusCode(),
    'request_id' => $requestId,
    'exception' => $e::class,
    'message'   => $e->getMessage(),
]);
```

### Bad → fix

```php
// ❌ string interpolation, no context, hard to grep
$this->logger->info("Loan $loanId disbursed for user $userId amount $amount");
// ✅
$this->logger->info('loan disbursed', ['loan_id' => $loanId, 'user_id' => $userId, 'amount' => $amount]);

// ❌ AI vibe, vague
$this->logger->info('Successfully processed and persisted comprehensive loan data');
// ✅
$this->logger->info('loan saved', ['loan_id' => $loan->getId()]);

// ❌ exception stringified, loses class + stack
$this->logger->error('error: ' . $e->getMessage());
// ✅ — Monolog auto-resolves under 'exception' key
$this->logger->error('loan save failed', ['loan_id' => $loanId, 'exception' => $e]);

// ❌ logging then re-throwing same info → double noise
try { ... } catch (\Throwable $e) {
    $this->logger->error('failed', ['exception' => $e]);
    throw $e;
}
// ✅ — log OR rethrow. If rethrowing, let the top-level handler log it.
```

## Level decision tree

```
Did something go wrong?
├─ no, normal flow  ──► info (or debug if noisy)
└─ yes
    ├─ recoverable, caller continues  ──► warning
    ├─ this request/job failed, but service alive  ──► error
    └─ data corrupt / invariant broken / oncall needed  ──► critical
```

| Level | Use for | NOT for |
|---|---|---|
| `debug` | dev-only trace, loop bodies, intermediate values | anything prod-relevant |
| `info` | business event success, request entry, command start/end | every method call |
| `warning` | recoverable failure, business rule reject, retry, deprecated path | unexpected exceptions |
| `error` | request/job failed, external dep down, unhandled domain error | recoverable cases |
| `critical` | data corruption, invariant violated, paging-worthy | normal API 4xx/5xx |

`emergency` / `alert` / `notice` — defined in PSR-3 but unused in this repo. Stick to the five above.

## Exception logging

Pass the exception object under key `exception`. Monolog's `PsrLogMessageProcessor` + `IntrospectionProcessor` resolve class, file, line, stack.

```php
try {
    $this->irisClient->send($payload);
} catch (\Throwable $e) {
    $this->logger->error('iris send failed', [
        'user_id'   => $userId,
        'exception' => $e,
    ]);
    throw new IrisCallException('iris unavailable', 0, $e);
}
```

Never `$e->getTraceAsString()` into a string field — let Monolog format it.

## Channels (Monolog config)

Default channel — `app`. Common named channels in this stack:

| Channel | Use |
|---|---|
| `app` (default) | business logic |
| `request` | HTTP entry/exit (auto by Symfony) |
| `doctrine` | SQL (auto) — do not log here manually |
| `messenger` | async dispatch / consume |
| `iris`, `asc`, `plus`, `scoring` | per external integration |

To use a named channel: inject typehinted by argument name (`LoggerInterface $irisLogger`). Config it in `config/packages/monolog.yaml` under `monolog.channels`.

## Mongolian comments

Existing repo uses Mongolian for some comments and command descriptions. **Log messages stay English** — they're grepped by oncall + indexed by log infra. Comment around the log line can be Mongolian:

```php
// Зээл олгосон — IRIS рүү дамжуулна
$this->logger->info('loan disbursed', ['loan_id' => $id]);
```

## Privacy / secrets (HARD)

Never log:
- Passwords, tokens, JWTs, API keys, signed URLs.
- Full PAN / card number / CVV.
- National ID / register number (only last 4 if absolutely needed).
- Full request/response body of auth endpoints.
- Raw exception message from third-party libs if it may echo a secret.

If a value might carry a secret, redact:

```php
'authorization' => substr($header, 0, 8) . '...redacted',
'token_prefix'  => substr($token, 0, 4),
```

When you spot existing code logging a credential — flag to user, do not silently copy the pattern.

## Cron / command logging

```php
final class ProductExpireCommand extends Command
{
    public function __construct(private LoggerInterface $logger) { parent::__construct(); }

    protected function execute(InputInterface $in, OutputInterface $out): int
    {
        $this->logger->info('product expire start');
        try {
            $count = $this->service->expireDue();
            $this->logger->info('product expire done', ['expired' => $count]);
            return Command::SUCCESS;
        } catch (\Throwable $e) {
            $this->logger->error('product expire failed', ['exception' => $e]);
            return Command::FAILURE;
        }
    }
}
```

Always emit start + done. Long-running loops — emit a progress log every N items, not every iteration.

## Checklist (run mentally)

- [ ] PSR-3 `LoggerInterface` injected via constructor — never `new` and never static.
- [ ] Level matches the decision tree.
- [ ] Message is short English sentence, ≤80 chars, no interpolation, no period.
- [ ] Context is flat assoc, snake_case keys, ≤6 keys, scalar/json-able values.
- [ ] Identifier present (`loan_id`, `user_id`, `request_id`) so the line is greppable.
- [ ] Exceptions passed under `exception` key — never stringified.
- [ ] No PII, no secrets, no token, no PAN.
- [ ] Not duplicated by surrounding middleware / subscriber.
- [ ] Not inside a tight loop without `debug` gating.
- [ ] No log-and-rethrow pair.

## Anti-patterns

- ❌ `error_log()`, `var_dump`, `print_r`, `echo` in non-CLI code.
- ❌ `new Monolog\Logger(...)` instead of injecting PSR-3.
- ❌ String interpolation inside the message (`"failed for $id"`).
- ❌ Trailing period or exclamation in the message.
- ❌ Logging `$e->getMessage()` only — losing class + trace.
- ❌ Logging the full request body / `$_POST` / headers without redaction.
- ❌ `info` for an exception. `error` for a normal 200 response.
- ❌ Logging then immediately rethrowing the same exception.
- ❌ `$this->logger->log('ERROR', ...)` — call the named method.
- ❌ AI vibe: `comprehensive`, `successfully`, `robust validation`, `leverage`, `seamless`. Use simple verbs.
- ❌ Camel-case or capitalized context keys (`UserId`, `loanID`) — use `user_id`, `loan_id`.
