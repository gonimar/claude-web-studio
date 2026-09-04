# Agent Spec: game-lead

> **Tier**: leads · **Spec written**: 2026-09-05

## Summary
**Domain**: Web-game architecture: loop, client, frame budget, engine, assets, multiplayer, game code review
**Does not own**: Non-game server business logic, UX specs (design-lead)
**Escalates to**: technical-director
**Delegates to**: threejs-engineer, web-game-engineer, multiplayer-engineer
**Reference**: `stack-reference/threejs-webgames.md`
**Verdict vocabulary**: PLAYABLE / PARTIAL / BLOCKED; APPROVED / NEEDS CHANGES

## Static checks
- [ ] agent file `game-lead.md` with `name/description/model/tools`
- [ ] references named · [ ] responsibilities and principles · [ ] Collaboration protocol

## Cases
### 1. In domain — Feasibility of a 3D racing game on mobile web
**Expected**: Frame/memory/load budget, three.js r185 WebGPU + fallback, spikes
- [ ] budget numbers
- [ ] spikes named
### 2. Out of domain — "build subscription payments"
**Expected**: redirect to `backend-lead`, the work is not done by this agent.
- [ ] redirect
### 3. Verdict — Review of code with new Vector3 per frame and no dispose
**Expected**: NEEDS CHANGES
- [ ] allocations
- [ ] dispose
### 4. Conflict — design-lead wants a HUD expensive in draw calls
**Expected**: Measurement, options, escalation to TD
- [ ] measurement
### 5. Context from a parent — Game concept passed with a 100 draw-call budget
**Expected**: Uses the number
- [ ] context

## Protocol
- [ ] in domain · [ ] correct escalation · [ ] "May I write?" · [ ] draft before approval · [ ] no tier skipping
