# Persona-driven e2e testing

A **persona** is a user simulator (a small model prompt with a fixed character) that answers the
studio's questions during a headless run. Where `check.py` asserts mechanics, personas exercise
*judgement* the studio has to hold across a whole conversation: scope discipline, gate resilience,
handling a user who refuses, rushes, invents, or knows nothing. Every behavioural defect found so
far lived between skills, in exactly this space.

## How a persona run works

`drive.sh` feeds the studio's last turn to the persona model, which replies in character; the reply
becomes the next user turn. The **checker judges the studio, never the persona** — a persona that
plays its part badly is a harness bug, not a studio result. Personas answer in the project's
conversation language (the profile says so); profiles themselves are English so the linter passes.

## Profiles (this directory)

| Profile | Stress-tests |
|---|---|
| `agreeable` | baseline — does the pipeline railroad or flow when nothing resists it |
| `hasty` | gate resilience under "skip the ceremony, just code" pressure |
| `refusenik` | does a gate take "no" for an answer, or loop the same question |
| `inventor` | scope discipline — MVP boundaries against a flood of feature ideas |
| `clueless` | does the studio lead a novice with defaults instead of demanding expertise |

Add a profile as a new `<name>.md` here; keep it one character, no meta ("never discuss that this
is a simulation"), and end with "answer in the project's conversation language".

## Result storage & reports — the convention

Results are **not** stored in this repository. They live wherever the runner runs them (the lab that
drives these keeps them in its own out-of-git archive). Whoever stores them uses this layout:

```
<archive>/tests/
  NNNNNNN-<topic>/                 # zero-padded run number, one per test topic (helloworld, tetris)
    README.md                      # the scenario in one paragraph
    <persona>/                     # one subfolder per persona run
      code/                        # the project files the studio produced (no .git, no .claude)
      dialogue.turns.md            # per-turn: USER line ↔ STUDIO reply
      DESCRIPTION.md               # topic·mode tag + one-paragraph verdict (✅/⚠/✗)
  TEST-LOG.md                      # running log: behaviour tables, code evaluation, open questions
```

**Report rules:**
- One running `TEST-LOG.md` per archive; append, never rewrite history.
- Code evaluation is **independent of the studio's own `/code-review`** — rate the produced code on
  its merits (✅ good · ⚠ note · ✗ problem), and keep a **reviewer-comparison table** (studio review
  vs an independent pass) so the reviewer itself is tested, not just the code.
- File extensions match format: `.md` human-readable, `.jsonl` stream-json transcripts, `.err.log`
  stderr only.
- A finding needs evidence (a tool-event order, a file, a transcript line) before it is called a
  finding; otherwise it is a hypothesis and is labelled one.

## Known harness limits

- `AskUserQuestion` degrades to text in `-p` mode — assertions accept both.
- A fresh fixture is "untrusted": some writes are blocked until the workspace is trusted.
- The persona model can drift out of character on an unexpected turn — reinforce the no-meta line
  and feed it the studio's clean last turn, not an echo.
