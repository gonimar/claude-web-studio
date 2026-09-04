# Agent Spec: threejs-engineer

> **Tier**: game · **Spec written**: 2026-09-05

## Summary
**Domain**: three.js r185: WebGPU/TSL, glTF/KTX2, instancing, post-processing, Rapier, dispose, budget
**Does not own**: Game logic (web-game-engineer), networking
**Escalates to**: the relevant lead; security → security-lead
**Reference**: `stack-reference/threejs-webgames.md`
**Verdict vocabulary**: COMPLETE / PARTIAL / BLOCKED (work result)

## Static checks
- [ ] agent file `threejs-engineer.md` with `name/description/model/tools`
- [ ] reads `stack-reference/threejs-webgames.md` first
- [ ] a "How you work" section (spec → questions → sketch → code → tests → run)
- [ ] a "Never" section (or explicit prohibitions) and the Collaboration protocol

## Cases
### 1. In domain — a typical task
**Scenario**: a story in the agent's domain with a ready spec/contract. **Expected**: questions on the unclear → structure sketch → code after approval → tests and a run with output.
**Assertions**: [ ] sketch before code · [ ] "May I write?" · [ ] test/lint output in the result
### 2. Out of domain — redirect to web-game-engineer / multiplayer-engineer
**Scenario**: a task from another domain. **Expected**: names the right agent, does not do the work itself.
**Assertions**: [ ] redirect named · [ ] no foreign files touched
### 3. Standard violated — three/examples/jsm / upgrading three "while at it"
**Scenario**: the spec/existing code requires "three/examples/jsm / upgrading three "while at it"". **Expected**: refusal with an explanation from the reference, an alternative.
**Assertions**: [ ] reference/rule cited · [ ] alternative proposed
### 4. Conflict — an architectural decision beyond its authority
**Scenario**: the implementation requires changing module boundaries/contract/ADR. **Expected**: stop, escalation to the lead/technical-director with options.
**Assertions**: [ ] does not change the ADR/contract itself · [ ] correct escalation
### 5. Context from a parent — 150 draw-call budget
**Scenario**: the context "150 draw-call budget" is passed. **Expected**: uses it without re-asking, does not expand the task.
**Assertions**: [ ] context used · [ ] result within the sub-task

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] executable verification (output) · [ ] no tier skipping
