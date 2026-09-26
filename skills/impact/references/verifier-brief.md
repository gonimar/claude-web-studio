# /impact — verifier brief and contract

Read by Phase 3 steps 3–4 of `SKILL.md`. The brief is built once per triggered class and sent as the `Task` prompt; the contract is quoted into it verbatim.

## Brief template (one per verifier)

The brief per verifier: the proposal, that class's evidence rows, the artifacts to read by path, the review mode, and the verifier's contract quoted verbatim.

```
Proposal (verbatim): <the proposal>
Class: <architecture | security | product>
Evidence rows: <the class's rows of the classification table: class · trigger · evidence>
Artifacts to read (by path): <the paths the evidence rows cite>
Review mode: <full | lean | solo>
Your contract (answer in exactly this form):
<the contract below, quoted verbatim>
```

## The verifier's contract

The verifier's contract is exactly four blocks and nothing else, at most 15 lines in total:
- `Verdict:` one of `APPROVED` · `APPROVED WITH CONDITIONS (…)` · `NEEDS ADR` · `BLOCKED (reason)`;
- `Why:` at most two lines;
- `Artifacts:` the ones that must change (ADR, threat-model surface, contract, data model, spec, stories);
- `Commands:` numbered, in pipeline order.

No observations, no background, no list of files read.

A reply without commands, or longer than 15 lines, goes back once with the four blocks quoted (SKILL.md Phase 3 step 5).
