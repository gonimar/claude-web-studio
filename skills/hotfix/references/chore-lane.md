# `/hotfix --chore` — the chore/infra lane

Read from `SKILL.md` when the argument is `--chore <what>`: the toolchain is broken or in the way — a red runner, a linter that blocks every commit, a dependency that must move now. Phases 1–4 of `SKILL.md` do not run; the glossary (gate recording, namespaces) and the "parent writes no code" rule do. It skips the release machinery and follows the chore/infra lane of `git-workflow.md`:

1. branch `chore/<slug>` (`git fetch origin`, then `git switch -c chore/<slug> origin/<default>`);
2. commits `ci(…)` / `chore(…)`, each behind one commit gate recorded in the session state as the glossary says (`Gate "/hotfix chore: commit <what>?"`, cleared after the answer);
3. a PR with `/web-studio:code-review --diff` (copy mode `/code-review --diff`) run through the `Skill` tool before the merge (workflow files → `devops-engineer`); experimental commits are squashed or rebased away before the merge;
4. the outcome recorded as a finding (`production/findings.md`) or a backlog entry (`production/backlog.md`).

The PR is opened by the closing question of `SKILL.md` — open the PR (Recommended: `git push -u origin chore/<slug>` when the branch is local, then `gh pr create --fill --base <default>`) · stop here — and the verdict is `DONE (chore — PR open)`; on "stop here" it reads `DONE (chore — PR not opened)` and the report says where the branch is. No `/incident` after a chore: there was no incident.
