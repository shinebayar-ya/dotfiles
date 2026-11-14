---
name: bruno-collection
description: Generate Bruno OpenCollection 1.0 .yml files for REST endpoints in ANY repo. Triggers on /bruno, /bruno-setup, or when editing REST resource/controller/route files (e.g. `**/resource/**`, `**/controller/**`, `**/routes/**`, `**/api/**`). Two modes — add-endpoint (default) and setup (bootstraps `bruno/` if missing, see SETUP.md). Adapts to the repo's existing collection layout, host variables, and env catalog instead of imposing a fixed structure.
---

## Modes

| `bruno/opencollection.yml` | Mode |
|---|---|
| exists | **add-endpoint** (this file) |
| missing | **setup** — read `SETUP.md`, then return here |

Setup triggers: `/bruno-setup`, "setup bruno", "init bruno", "bootstrap bruno", or `/bruno` in a repo with no `bruno/`.

## Adapt to the repo FIRST (discovery)

This skill is repo-agnostic. Before generating anything, **read the existing collection and the repo** and conform to what is already there. Never impose a structure from another project.

Discover, in order:

1. **Host / base-URL variable(s)** — open `bruno/opencollection.yml` and `bruno/environments/*.yml`. Find the variable(s) used as the URL prefix (e.g. `{{base_url}}`, `{{app_base_url}}`, `{{merchant_api_gw}}`, `{{host}}`). Reuse the one that matches the target endpoint's service/gateway. **Never hardcode a literal host** — always `{{var}}`.
2. **Path prefix** — look at sibling request URLs already in the collection. Match the real route the endpoint is served at (from the resource annotation / router). Do **not** invent a version segment (`/api/v2`) unless the actual route has one.
3. **Folder layout** — list `bruno/`'s existing top-level folders and sub-folders. Slot the new endpoint into the matching domain folder. Only create a new folder when no existing one fits.
4. **Header set & auth style** — read the collection-level `request.headers` / `request.auth`. These are inherited; do **not** repeat them per request. Add a per-request header only when its value differs.
5. **Env var catalog** — the catalog is *whatever the collection's env files already define*. Reuse those names. There is no fixed/global catalog.
6. **Route source** — detect the framework only to read routes accurately: `pom.xml`/Gradle → JAX-RS/Spring (`@Path`/`@RequestMapping`); `package.json` → Express/Nest/Fastify; `go.mod`; `Cargo.toml`; or an OpenAPI/Swagger spec if present.

If a signal is absent (fresh `bruno/`), fall back to the conservative defaults noted per section below.

## Universal conventions (all repos)

1. Files are OpenCollection 1.0 **.yml** (not .bru).
2. Headers and auth defined **once** at collection level (`bruno/opencollection.yml`); never duplicate per request. Per-request header only when the value differs from the inherited one.
3. Every folder + request carries `auth: inherit` (unless the request genuinely needs a different auth).
4. Path/env substitution: `{{varName}}` double-brace. Never single-brace `{varName}`.
5. URL = `{{<discovered-host-var>}}/<real-route-path>`. Never hardcode hosts; never bolt on a version prefix the route doesn't have.

## Folder placement (generic)

Mirror the repo's own domain/module structure and the collection's existing top-level grouping. Heuristic, in priority order:

1. **Existing folder match** — if a folder already covers this endpoint's domain/entity, put it there.
2. **Route-derived** — else derive the folder from the route's leading segment(s) or the resource's package/module (e.g. route `/admin/merchants/...` → `admin/merchants/`; package `…/billing/InvoiceResource` → `billing/invoices/`).
3. **Group by entity** when a domain accumulates many endpoints (one sub-folder per entity).
4. **Scope prefix** (`superadmin-`, `admin-`, `internal-`, `public-`, `current-`) only when the repo actually distinguishes audiences/actors and the existing layout already uses such prefixes.

Folder names are kebab-case plural nouns (see Naming). Keep nesting depth aligned with how the collection is already organized — don't flatten or over-nest relative to siblings.

## Naming convention (STRICT)

### Request file: `<Verb> <Entity>[ <Modifier>].yml`

Rules (all required):

| # | Rule |
|---|---|
| 1 | Title Case, ASCII, space-separated. No `_` / `-` / `[]` / `:` / `()`. |
| 2 | Max 4 words preferred, hard cap 5. ≤30 chars total. |
| 3 | Verb first, exactly one verb, from canonical table below. |
| 4 | Cardinality matches HTTP: collection GET = plural, single GET = singular. |
| 5 | No folder-name repeat, no filler (`Endpoint`/`API`/`Request`/`Service`/`Handler`/`Operation`/`Action`), no implementation hint (`By ID From DB`, `With Pagination`, version/`internal` tags). |
| 6 | No prepositions unless semantically required. |
| 7 | Two requests in one folder collide → disambiguate the less-canonical one with a short Modifier. |

### Canonical verb table

| HTTP | Semantic | Verb | Example |
|---|---|---|---|
| GET (1) | Read single | `Get` | `Get User` |
| GET (n) | Read collection | `List` | `List Users` |
| GET | Search/filter | `Search` | `Search Orders` |
| GET | Existence check | `Check` | `Check Email Exists` |
| GET | Computed/derived | `Resolve` | `Resolve Price` |
| POST | Create | `Create` | `Create Order` |
| POST | Idempotent create-or-update | `Upsert` | `Upsert Setting` |
| POST | Bulk | `Bulk <Verb>` | `Bulk Create Users` |
| POST | RPC-style domain action | domain verb | `Login`, `Authorize`, `Pay`, `Cancel`, `Send` |
| PUT | Full replace | `Update` | `Update User` |
| PUT | Upload binary | `Upload` | `Upload Avatar` |
| PATCH | Partial update | `Patch` | `Patch User` |
| DELETE | Hard delete | `Delete` | `Delete Order` |
| DELETE/POST | Soft delete | `Revoke` | `Revoke Token` |
| POST/PUT | Restore | `Reactivate` | `Reactivate Account` |
| POST | Import/sync trigger | `Import`/`Sync` | `Sync Catalog` |

A POST/GET used for read/list (RPC-style query) is named by **semantics** (`List`/`Get`/`Search`), not by the HTTP method. If both PUT and PATCH exist for one entity: `Update` = PUT, `Patch` = PATCH. Otherwise `Update` for either.

### Folder name (`folder.yml` → `info.name`)

kebab-case, 1-2 words (cap 3), plural noun, no verbs. Scope-prefix only when the repo distinguishes actors/audiences (see Folder placement).

### Env var name

Match the naming style the collection's env files already use (camelCase, snake_case, or kebab — be consistent with siblings). Name by conceptual identity, not by request.

- ✅ `userId`, `orderId`, `authToken` — reused, conceptual
- ❌ `createOrderUserId` (request-specific), `req3Email` (positional)

### Examples (good vs bad)

| ❌ Bad | ✅ Good | Reason |
|---|---|---|
| `Fetch All Users Endpoint.yml` | `List Users.yml` | filler, jargon |
| `Get User By ID From DB.yml` | `Get User.yml` | implementation hint |
| `User Create Request.yml` | `Create User.yml` | verb not first |
| `Update User Metadata PATCH.yml` | `Patch User.yml` | HTTP method in name |
| `delete_order.yml` | `Delete Order.yml` | snake_case |
| `Authenticate User Login Action.yml` | `Login.yml` | filler |

## File structure

### Folder

```yaml
info:
  name: <folder-name-kebab>
  type: folder
  seq: <1-based int, unique within parent>

request:
  auth: inherit
```

### Request — mandatory blocks

```yaml
info:
  name: <Same as filename without .yml>
  type: http
  seq: <int unique within folder>

http:
  method: <GET|POST|PUT|PATCH|DELETE>
  url: "{{base_url}}/<real-route-path>"   # {{base_url}} = whatever host var the collection uses
  # body present only for POST/PUT/PATCH/multipart
  auth: inherit

settings:
  encodeUrl: true
  timeout: 0
  followRedirects: true
  maxRedirects: 5
```

`{{base_url}}` above is a placeholder for the **discovered** host variable — use the collection's actual one.

### Request — by shape

**GET with query params:**
```yaml
http:
  method: GET
  url: "{{base_url}}/users"
  params:
    - name: page
      value: 1
      type: query
    - name: limit
      value: 20
      type: query
  auth: inherit
```

Use the pagination/sort conventions the collection already uses; if none, sensible defaults are `page=1` / `limit=20`.

**GET with path param:**
```yaml
url: "{{base_url}}/users/{{userId}}"
```

**POST / PUT / PATCH with JSON body:**
```yaml
http:
  method: POST
  url: "{{base_url}}/orders"
  body:
    type: json
    data: |-
      {
        "userId": "{{userId}}",
        "status": "PENDING"
      }
  auth: inherit
```

JSON body uses `|-` block scalar. Values follow Payload extraction policy below.

**Multipart upload:**
```yaml
http:
  method: PUT
  url: "{{base_url}}/users/{{userId}}/avatar"
  body:
    type: multipart-form
    data:
      - name: file
        type: file
        value:
          - "{{upload_file_path}}"
  auth: inherit
```

`multipart-form` uses `data:` (not `form:`) — verified against `packages/bruno-filestore/src/formats/yml/common/body.ts` in usebruno/bruno. Entry fields: `name`, `type` (`text` or `file`), `value` (a path/string for `text`, an array of file paths for `file`), plus optional `contentType`, `description`, `disabled`. `form-urlencoded` also uses `data:` — same key for both form-shaped body types.

**DELETE:**
```yaml
http:
  method: DELETE
  url: "{{base_url}}/orders/{{orderId}}"
  auth: inherit
```

### Request — tests & assertions

Two mechanisms, both under a top-level `runtime:` block (sibling of `info`/`http`/`settings`). Verified against the shipped implementation (`packages/bruno-js/src/runtime/assert-runtime.js` in usebruno/bruno) — do not use older `.bru`-style bare `assert { }` / `tests { }` blocks in YAML files.

**Script-based tests** (`runtime.scripts`, `type: tests`) — Chai assertions, use when the check needs JS (multiple related expects, computed values, non-header/body reads via `res.getHeader()`/`res.getStatus()`/etc.):

```yaml
runtime:
  scripts:
    - type: tests
      code: |-
        test("x-continue header is true", function() {
          expect(res.getHeader('x-continue')).to.equal('true');
        });
```

Other `scripts[].type` values: `before-request`, `after-response` (plain JS, no `test()`/`expect()` wrapper).

**Declarative assertions** (`runtime.assertions`) — no JS, use for simple status/header/body checks:

```yaml
runtime:
  assertions:
    - expression: res.headers['x-continue']
      operator: eq
      value: "true"
    - expression: res.body.status
      operator: eq
      value: success
```

Fields: `expression` (`res.status`, `res.body.<path>`, `res.headers['<name>']`, `res.responseTime`), `operator`, `value` (omit for unary operators). **Operator names are `eq`/`neq`, not `equals`/`notEquals`** — Bruno's own docs disagree with each other here (structure-reference.md says `eq`/`neq`, testing/tests/assertions.md says `equals`/`notEquals`); the shipped `switch` in `assert-runtime.js` only matches `eq`/`neq` — an unmatched operator string silently falls through to its `default` case (also an eq-equivalent check), so `equals` happens to still "work" for plain equality but is undocumented fallthrough, not a real operator. Always use the source-verified list: `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `in`, `notIn`, `contains`, `notContains`, `length`, `matches`, `notMatches`, `startsWith`, `endsWith`, `between`, `isEmpty`, `isNotEmpty`, `isNull`, `isUndefined`, `isDefined`, `isTruthy`, `isFalsy`, `isJson`, `isNumber`, `isString`, `isBoolean`, `isArray`.

Pick one mechanism per check based on what the user asked for (script vs assertion) or, absent a preference, assertions for a single header/body/status check and a script when multiple related expects belong together.

## Payload extraction policy

Goal: request files static, payload tweaks live in env files (not committed file edits).

### Decision tree

```
Need to change payload locally?
├─ Same value across requests? ────► env var (reuse the collection's catalog)
├─ Per-developer / per-DB? ────────► env var (local.personal.yml, gitignored)
├─ One-off scratch? ───────────────► Bruno UI Variables tab
├─ API enum / contract constant? ──► literal
└─ Generated per run? ─────────────► pre-request script (`bru.setVar`)
```

### Extract to env var when ANY of:
- Identifier (uuid, id, slug, email tied to seed row)
- Reused across ≥2 requests
- Differs per local DB / developer
- Environment-coupled (URL, secret, file path)
- Mutates per run (tokens, prior-request IDs)

### Keep as literal when ALL of:
- API-contract value (enum, protocol constant)
- Used exactly once AND not seed-tied
- Documents schema shape
- Boolean / small int with semantic meaning

Local overlay (`local.personal.yml`, `.gitignore` entries) → see `SETUP.md`.

## Sequencing

- `seq` 1-based, unique within parent.
- New request: max(existing) + 1. Do not renumber siblings unless reordering.
- CRUD folder order: `List` → `Get` → `Create` → `Update`/`Patch` → `Delete` → side ops (`Upload`, `Revoke`, `Reactivate`).

## Environments

The env files and their variables are **whatever the repo already has** in `bruno/environments/`. Discover and reuse them:

- Reuse existing var names; don't invent parallel names for the same concept.
- A net-new env var → add it to **every** env file present (so all environments resolve), then flag it to the user.
- Host/gateway/base-URL vars and secrets live in env files, never hardcoded in requests.
- Secrets (tokens, keys, passwords) belong in a gitignored `local.personal.yml`, not the committed env file. Flag any committed secret you encounter and suggest rotation.

For a brand-new collection, `SETUP.md` defines the starter env shape.

## Route → Bruno sanity check (framework-agnostic)

When generating from a resource/controller/route, verify:

1. Route path + method map to the Bruno `url` + `method` exactly (e.g. JAX-RS `@Path("/foo")` + `@GET @Path("/{id}")` → `GET {{base_url}}/foo/{{id}}`; Express `router.get('/foo/:id')` → same).
2. Query params → `params: [{ name, type: query }]`. Path params → `{{var}}` segments.
3. Required auth/headers → pick the env (and any per-request header overrides) that supplies what the endpoint needs. If the endpoint targets a different gateway/service than the collection default, use that service's host var.
4. Audience/scope (admin vs public vs internal) → place in the matching folder per the collection's existing convention.
5. Public/unauthenticated endpoints → still inherit collection headers; that's harmless.

## Validation

After write, parse-check the file:

```bash
command -v bru && cd bruno && bru run "<path>" --env <env> || \
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" bruno/<path>.yml
```

If `python3` lacks PyYAML, use a venv or any YAML linter. Parse + URL/var resolution is the bar — a 2xx response is not required (local env may lack live gateway headers).

## Checklist (run mentally, no exceptions)

Discovery:
- [ ] Reused the collection's existing host var, header set, folder layout, and env catalog — did not impose an external structure.

Naming + lint:
- [ ] Filename: verb from canonical table, cardinality matches HTTP, ≤30 chars, no filler/jargon/folder-repeat/preposition/impl-hint.
- [ ] Folder `info.name`: kebab-case, plural noun, no verb.
- [ ] Env var uses conceptual identity in the collection's existing naming style.

Structure:
- [ ] `.yml`, not `.bru`. `info.name` matches filename.
- [ ] `info.type` = `http` (request) or `folder`.
- [ ] `seq` set, unique within parent.
- [ ] `http.auth: inherit` (or a deliberate per-request auth).
- [ ] `url` uses a `{{host-var}}` + the real route path. No hardcoded host, no invented version prefix.
- [ ] Placeholders use `{{ }}`.
- [ ] `settings` block with four standard keys.
- [ ] Parent folder has `folder.yml`.

Payload:
- [ ] Identifiers/reused/per-dev → env vars. Enums/constants → literal.
- [ ] Net-new env vars added to every env file present.

## Anti-patterns

- ❌ `.bru` files (collection is OpenCollection .yml).
- ❌ Mixing `{var}` and `{{var}}` in one file.
- ❌ Hardcoded hosts, or a version prefix (`/api/v2`) the real route doesn't have.
- ❌ Per-request `headers`/`auth` that just duplicate the inherited collection-level ones.
- ❌ Imposing another project's folder tree, env catalog, or var names instead of the repo's own.
- ❌ Random `seq` numbers — keep dense and ordered.
- ❌ Request-specific env var names.
- ❌ Bare `.bru`-style `assert { }` / `tests { }` blocks in a YAML request — YAML uses `runtime.assertions` and `runtime.scripts` (`type: tests`).
- ❌ `operator: equals`/`notEquals` in `runtime.assertions` — the shipped code only matches `eq`/`neq` (see Request — tests & assertions).
- ❌ `body.form:` for multipart — the field is `body.data:` (same key as `form-urlencoded`).
