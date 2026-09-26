# Skill Spec: /api-contract

> **Category**: authoring · **Priority**: critical · **Spec written**: 2026-09-05

## Summary
Contract: GraphQL SDL by default / OpenAPI / WS; diff; codegen.

## Static checks
- [ ] Frontmatter: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] ≥ 2 phases · [ ] a verdict word · [ ] "May I write?" with Write/Edit · [ ] a next step · [ ] a reference/template/rules link

## Cases
### 1. Happy path
**Fixture**: F-002, GraphQL. **Expected**: SDL with connections, payload errors, @auth; inspector diff; examples.
- [ ] phase order followed · [ ] output matches the expectation · [ ] writes only after consent
### 2. Refusal / BLOCKED
**Fixture**: no feature spec. **Expected**: stops.
- [ ] stops or explicitly flags the limitation · [ ] names the command/reason · [ ] writes no files
### 3. Mode/argument variant
**Fixture**: --style rest → OpenAPI + spectral. **Expected**: behaviour differs from case 1 according to the argument.
- [ ] argument parsed · [ ] the difference matches the skill description
### 4. Edge case
**Fixture**: breaking change → BREAKING (N) and leads notified. **Expected**: handled explicitly, never silently skipped.
- [ ] the case is mentioned in the instructions · [ ] correct message/action
### 5. Gate / protocol
**Fixture**: written after consent. **Expected**: the user decides; stage/statuses never change automatically.
- [ ] no self-advancing · [ ] verdict from the skill's vocabulary

### 6. `--deprecate` with external consumers
**Fixture**: `/api-contract --deprecate Query.userByEmail --remove-after 2026-12-31`; the replacement `Query.user(id)` exists. **Expected**: `@deprecated(reason: "use user(id); removed after 2026-12-31")` in the SDL, the CI rule that fails after the date while the field exists, a `BREAKING` changelog entry (major bump), a removal story `📅 2026-12-31` handed to `/create-stories`, consumers from the ADR listed; removal without a period → `BREAKING (1)` and an explicit owner answer.
- [ ] deprecation in the contract · [ ] CI date rule · [ ] removal story and BREAKING entry

### 7. Documents lane (commit after write)
**Fixture**: Go module, `api_contract_path` = `api/schema.graphqls`; schema and `docs/architecture/api/api-contract.md` written on the default branch with no story in progress. **Expected**: right after the write one commit gate offers `docs: api contract F-002` staging exactly the two files, on the default branch (the hooks' documents lane lists `api/schema.graphqls`, `graph/schema.graphqls` and `api/openapi.yaml`, so the commit raises no branch warning); `Gate: /api-contract Phase 5: commit?` is recorded in session-state before the question and cleared after the answer; on a story branch the three options (switch and commit there Recommended · commit here · leave uncommitted); generated types and the codegen task are named for the chore lane or the first story, never staged in the `docs:` commit; nothing is committed without the answer.
- [ ] commit gate follows the write · [ ] schema outside docs/ still in the docs commit · [ ] codegen kept out · [ ] gate recorded and cleared

### 8. Contract path outside the documents lane
**Fixture**: `/adopt` set `api_contract_path` = `internal/graph/schema.graphqls` from `gqlgen.yml`; schema and `api-contract.md` written. **Expected**: the gate question says the schema path is outside the hooks' documents lane; the schema is committed as `chore(contract): F-002` on a `chore/<slug>` branch with a PR, never as `docs:` on the default branch; the `docs:` commit carries `api-contract.md` (and technical-preferences) only.
- [ ] lane membership stated · [ ] `chore(contract)` on a chore branch · [ ] docs commit without the schema

## Protocol
- [ ] "May I write?" · [ ] draft before approval · [ ] next step · [ ] artefacts over claims (command output)
