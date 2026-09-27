# Eval suite

Behavioural evals for the critical skills, run with `claude plugin eval` (Claude Code ≥ 2.1.269).
Layout: `evals/<skill>/<case>/` with `case.yaml` (name, the spec case it comes from, `scaffold_script`),
`prompt.md` (turn/time caps, tools, the prompt) and `graders/*.md`. `_lib/` holds the scaffold helpers
that build the synthetic fixtures of `testing/e2e/fixtures/` in the run's workspace.

```bash
claude plugin eval . --trust-plugin --scaffold --allow-tools Bash Write Edit Agent --ablation none --runs 1
claude plugin eval . --trust-plugin --scaffold --allow-tools Bash Write Edit Agent --case 'dev-story-*'
```

How evals relate to the specs in `testing/`, and the CI job: `testing/README.md` § Evals.
`results/` is gitignored.
