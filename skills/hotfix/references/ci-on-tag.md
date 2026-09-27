# CI on the patch tag (Phase 3 step 5)

Read from `SKILL.md` step 3.5, after the tag `vX.Y.Z` is pushed and before `/deploy`.

**CI builds the image from the tag.** Find out what starts on the tag before waiting for anything: `grep -l "tags:" .github/workflows/*.yml` and each such workflow's `on: push: tags:` pattern — the tag must match it (`v*` matches `vX.Y.Z`). With a matching workflow, wait for the tag's run before deploying — one background `gh run watch <run-id> --exit-status`, only for a run that exists; no polling, no `AskUserQuestion` as a pause. Red → `BLOCKED (CI red on vX.Y.Z)`, nothing deployed. Without a tag trigger, nothing starts on the tag: say so, name the run to expect instead (a `push` run on the branch, or a `workflow_dispatch` the user starts by hand) or that no run starts at all, and that `/deploy` will then find no green run on the tag. Without `gh`, name the run to check by hand.

Outcomes back in `SKILL.md`: green → step 3.6 (`/deploy vX.Y.Z`); red → `BLOCKED (CI red on vX.Y.Z)`; no tag trigger or no `gh` → the report names the run to expect or check, and `/deploy` may find no green run on the tag.
