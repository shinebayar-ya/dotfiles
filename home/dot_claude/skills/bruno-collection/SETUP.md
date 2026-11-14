# Bruno Collection — Setup Mode

Bootstrap a `bruno/` workspace from scratch, in **any** repo. Detect the repo's own conventions; impose nothing external.

## Pre-flight

1. `pwd` — confirm repo root.
2. `ls bruno/ 2>/dev/null` — non-empty → abort, switch to add-endpoint mode.
3. Detect signals to pre-fill answers:
   - **Project name**: `basename $(git rev-parse --show-toplevel)`, or artifact id from `pom.xml` / `package.json` / `go.mod` / `Cargo.toml`.
   - **Framework / route style**: `pom.xml`/Gradle (JAX-RS/Quarkus/Spring), `package.json` (Express/Nest/Fastify), `go.mod`, `Cargo.toml`, or an OpenAPI/Swagger spec.
   - **Dev URL**: grep `application.properties` / `application.yml` / `.env*` / framework config for a port key (`quarkus.http.port`, `server.port`, `PORT`, `SERVER_PORT`). Default `8080` if none.
   - **Auth / header hints**: grep for a security filter, gateway forwarded-headers (`x-*`, `authorization`), or an existing Postman/Insomnia export to mirror.

## Questions (AskUserQuestion, batched)

| # | Question | Default |
|---|---|---|
| 1 | Collection name | repo basename |
| 2 | Local base URL | `http://localhost:<detected-port>` |
| 3 | Auth/header style | `none` / `bearer` / `gateway` / `custom` |
| 4 | Top-level module folders | `general` only (Health Check + Swagger UI) |

Skip questions when args supplied (e.g. `/bruno-setup name=foo url=http://localhost:3000 headers=bearer modules=users,orders`).

## Files

### `bruno/opencollection.yml`

Skeleton:
```yaml
opencollection: 1.0.0
info:
  name: <collection-name>
config:
  proxy:
    inherit: true
    config:
      protocol: http
      hostname: ""
      port: ""
      auth:
        username: ""
        password: ""
      bypassProxy: ""
request:
  <AUTH>
  headers:
    <HEADERS>
bundled: false
extensions:
  bruno:
    ignore:
      - node_modules
      - .git
```

`<AUTH>` / `<HEADERS>` by style:

| Style | `<AUTH>` | `<HEADERS>` |
|---|---|---|
| `none` | (omit) | `[]` |
| `bearer` | `auth:\n    type: bearer\n    token: "{{token}}"` | `[]` (or `Accept-Language` etc. if the repo needs one) |
| `gateway` | usually `bearer` + a forwarded-identity header set | the `x-*` / forwarded headers this repo's gateway injects — **discover the actual names** from code, an existing export, or ask the user. Each value `"{{<var>}}"`. |
| `custom` | per user | user-supplied list, each `"{{<var>}}"` |

`gateway` has no fixed header list — it is whatever the repo's gateway uses (e.g. `x-api-gw-*`, `x-forwarded-user`, `x-tenant-id`). Never copy another project's header names blindly.

### `bruno/environments/local.yml`

```yaml
name: local
variables:
  - name: <base-url-var>      # the name requests will reference, e.g. base_url / app_base_url
    value: <local-base-url>
  <VARS>
```

`<VARS>` by style:

| Style | Vars |
|---|---|
| `none` | (just the base-url var) |
| `bearer` | `token: ""` |
| `gateway` | one var per gateway header (matching `<HEADERS>`) + `token: ""` |
| `custom` | derive from the header/auth list |

Keep the var set minimal at bootstrap; it grows as endpoints are added. Use one consistent naming style (camelCase or snake_case) — match the repo if it has an existing convention.

### Additional env files (optional)

Only if the project targets multiple environments/gateways. Mirror `local.yml`'s shape, one file per environment (e.g. `test.yml`, `staging.yml`, or per-gateway files). Don't create speculative env files.

### `local.personal.yml` — DO NOT create

Gitignored; the developer creates it manually for real local secrets. Final report includes the hint. **Never commit secrets** (tokens, keys, passwords) to `local.yml`.

### `.gitignore` (idempotent append)

```
# Bruno personal environments
bruno/environments/local.personal.yml
bruno/environments/*.local.yml
bruno/environments/*.secret.yml
```

Pattern: `grep -q "bruno/environments/local.personal.yml" .gitignore || echo "<block>" >> .gitignore`. Never overwrite. Create `.gitignore` if missing.

### `bruno/general/` (sample requests)

Folder.yml: `name: general`, `seq: 1`. Request files use SKILL.md request template, referencing the base-url var.

| File | Method | URL (default by framework) |
|---|---|---|
| `Health Check.yml` | GET | Quarkus `/q/health` · Spring `/actuator/health` · Express `/health` (omit if none) |
| `Swagger UI.yml` | GET | Quarkus `/q/swagger-ui` · Spring `/swagger-ui/index.html` · else the project's docs path (omit if none) |

Use the real health/docs paths for the detected framework; omit a sample if the framework has no convention and none is configured.

### Module folders (per Q4)

Per module name: `bruno/<module>/folder.yml` with `name: <module>` (kebab plural), `type: folder`, `seq: <next-int>`, `request: { auth: inherit }`. No sample requests inside — those come from add-endpoint mode. Name modules after the repo's real domains/route segments, not a generic template.

## Order

1. Pre-flight → 2. Ask → 3. Create dirs → 4. Write files (opencollection → envs → general + samples → modules) → 5. Verify YAML → 6. `git status bruno/ .gitignore` → 7. Print report.

Verify command:
```bash
command -v bru && cd bruno && bru run --env local 2>/dev/null; \
  python3 -c "import yaml,glob; [yaml.safe_load(open(f)) for f in glob.glob('bruno/**/*.yml', recursive=True)]"
```
(If `python3` lacks PyYAML, use a venv or any YAML linter.)

## Idempotency

Skip-if-exists (no overwrite): `bruno/opencollection.yml`, `bruno/environments/local.yml`, `bruno/general/Health Check.yml`. `.gitignore`: grep-append only. Re-runs fill missing, leave existing.

## Report (final output)

Per file: `[created]` or `[exists, skipped]`. Then:

```
Bruno setup complete.
Created:
  bruno/opencollection.yml
  bruno/environments/local.yml
  bruno/general/folder.yml
  bruno/general/Health Check.yml
  bruno/general/Swagger UI.yml
  bruno/<module>/folder.yml  (xN)
.gitignore: +3 lines

Next step:
  cp bruno/environments/local.yml bruno/environments/local.personal.yml
  # Edit local.personal.yml with real local values / secrets (gitignored).

Add first endpoint: /bruno <resource-or-route>
```

Paths only. Do not inline YAML.
