---
paths: ["**/*.go", "**/*.php", "**/*.ts", "**/*.tsx", "**/*.mts", "**/*.js", "**/*.mjs", "**/*.vue"]
---
# Comment rules (all languages)

A comment is written for the next reader of the code, not for the reviewer of this story. Two kinds exist, each with
its own reader; everything else belongs in the commit message, the PR or the story card.

- **Doc comment** (godoc / PHPDoc / TSDoc, above an exported symbol) is the **contract**: one to five sentences starting
  with the symbol's name — what it returns or does, special cases, concurrency guarantees, sentinel errors, what the caller
  must close or release. It is rendered by `go doc`, phpDocumentor and TypeDoc, so it is the API documentation and reads
  as one. Never the algorithm, never the story that produced it (Go's own rule: "doc comments should not explain internal
  details such as the algorithm used in the current implementation; those are best left to comments inside the function
  body"). Every exported symbol has one; unexported ones only when the behaviour is not obvious from the name.
- **Body comment** is the **reason**: an invariant, a race, a library bug being worked around, a non-obvious algorithm
  or a measured trade-off — one paragraph. A reason longer than a paragraph is an ADR or a `docs/` page and the comment
  is one line with the link. One ADR reference is allowed where the decision would otherwise look like a mistake
  (`// Never cached: ADR-0011 §7.`) — a reference, not a retelling.
- **Not in code**: story and finding IDs, "pre-S-050", "used to", "previously", "was … until", what a review round found
  or asked, what is or is not in this story's scope, who wrote it. It is true for one merge and misleading after — a
  later agent reads `pre-S-050` as a requirement. The PR and the story card keep that history. Comment density is a
  cost too: a third of a file in comments is a third of every agent's read budget on that file.
- **Tests are the one exception** for IDs: a regression test names what it pins in a single line — `// Regression: OPS-008.`
  or `// Issue #123.` — the way the Go standard library does; nothing more.
- **TODO carries an id or does not exist**: `TODO(S-123): what to do` for a story, `TODO(I-045): …` for a backlog idea
  (`FIXME`/`HACK` the same). A gap with no card yet is `/backlog add` first, then the TODO with its id. No dates, no names,
  no bare `TODO:` — it never reaches `/tech-debt`, and prose like "left as a follow-up if a future story wants" is a TODO
  hiding from the inventory. `/code-review` warns on a bare TODO, `/story-done` checks every new TODO's id exists,
  `/tech-debt` lists TODOs whose id is closed or unknown.
- No comment restates the code, no commented-out code, no header banners; a comment that has to say "this is wiring" or
  "this is fine" is a finding about the code (`rules/go-code.md` layout check).
- New code only: an existing file is not re-commented in passing — a `chore` story per package with this file as its
  acceptance criterion, never a drive-by in a feature diff.

Language forms: Go — `// Name …` full sentences, `revive` (`exported`, `package-comments`) and `godot` in `.golangci.yml`;
PHP — a docblock only for what the signature cannot say (generics `array<int, Recipe>`, `@throws`, `@deprecated`),
Slevomat `UselessFunctionDocComment`/`EmptyComment`/`ForbiddenComments` through `ecs.php`; TypeScript — TSDoc summary
first, details under `@remarks`, no `@param` types (they are in the signature), `eslint-plugin-jsdoc` + `unicorn/expiring-todo-comments`.
