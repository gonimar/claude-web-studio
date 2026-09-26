# /init — Re-run hand-off (Phase 6, `ALREADY INITIALISED`)

Read from Phase 6 step 2 after the verdict `ALREADY INITIALISED (N files differ)`. The Recommended option is decided by facts, not by a default, and **exactly one option is marked Recommended**. The facts are checked in this order and the first that holds decides; the others are still offered as alternatives:

1. the seeded documents are behind the studio — plugin mode: `diff -rq <root>/docs .claude/docs` and `diff -rq <root>/rules .claude/rules` list files that differ, ignoring `technical-preferences.md`, `local-overrides/`, `PROJECT-README.md` (it lives at `docs/web-studio/README.md`) and `readme/*` (translations; they would inflate N); copy mode: there is no `<root>` and no diff — `.claude/.web-studio-version` older than the kit's `.claude-plugin/plugin.json` when the kit path is known (`--plugin-root` or named by the user); kit path unknown → this fact cannot be established, say so and go to 2 — → `/update` (Recommended — the seeded docs and rules are behind the studio, and `/adopt` would audit stale references);
2. otherwise `technical-preferences.md` still a placeholder, or no `docs/adoption-plan-*.md` on a project with code → `/adopt full` (Recommended);
3. otherwise `/help` (Recommended).

When both 1 and 2 hold, `/update` is Recommended and `/adopt full` is the second option with the note "after /update".
"Do nothing" is never the recommended option on a project that has code.

The same diff (with the same ignore list) yields N for the verdict: the seeded files whose content differs from the seed root, listed by name in the Phase 3 plan.
