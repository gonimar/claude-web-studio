---
updated: 2026-09-05
sources: [https://threejs.org/docs, https://github.com/mrdoob/three.js/releases, https://github.com/mrdoob/three.js/wiki/Migration-Guide, https://pixijs.com/llms.txt, https://doc.babylonjs.com/llms.txt, https://docs.phaser.io, https://developer.mozilla.org/docs/Web/API/WebGPU_API]
---
# three.js r185 and browser games

## three.js
- **r185 (2026-07-01)**; ~monthly releases, **no SemVer** — every r-release may break APIs. **Pin the exact version**; upgrade deliberately via the Migration Guide (wiki), never "while at it".
- Imports: `three`, `three/webgpu` (WebGPURenderer), `three/tsl` (Three Shading Language), addons from `three/addons/*` (the old `three/examples/jsm` path is not used).
- **WebGPURenderer** is the main path with automatic WebGL2 fallback. Materials are node-based (`MeshStandardNodeMaterial` and TSL) for WebGPU; classic `ShaderMaterial`/GLSL only on the WebGL path. Post-processing: `three/addons/postprocessing` (WebGL) or `PostProcessing` + TSL passes (WebGPU).
- Loading: `GLTFLoader` + `DRACOLoader`/`KTX2Loader`/meshopt; textures in **KTX2** (Basis), geometry via Draco/meshopt; glTF is the only production asset format.
- Optimisation: `InstancedMesh`/`BatchedMesh`, `three-mesh-bvh` for raycasts, LOD, default frustum culling, `renderer.info` for draw calls; devicePixelRatio cap 2; `renderer.setAnimationLoop`; **`dispose()`** geometry/material/texture when leaving a scene; no allocations per frame (reuse `Vector3`).
- Colour: `ColorManagement.enabled = true` (default), `outputColorSpace = SRGBColorSpace`, tone mapping (`ACESFilmic`/`AgX`); colour textures sRGB, data textures linear.
- Physics: **Rapier** (`@dimforge/rapier3d-compat`), alternatives cannon-es/ammo; fixed step (`1/60`) with an accumulator, render interpolated.
- Framework integration: **Vue — TresJS** (`@tresjs/core`, Vue 3.5+) or a manual `<canvas>` with `markRaw`; **Angular — angular-three** (signals) or a manual service outside change detection; in both cases scene state lives outside framework reactivity, the UI overlay lives in the framework.
- Debugging: `lil-gui`, `stats-gl`, Spector.js / WebGPU inspector, `three-devtools`.

## Other engines (choice recorded in technical-preferences)
| Engine | Version | When |
|---|---|---|
| **PixiJS 8** | 8.x (WebGPU + WebGL) | 2D games and UI-heavy scenes; sprites, atlases, filters |
| **Phaser** | 3.90 / 4.x | 2D games "out of the box": scenes, physics (Arcade/Matter), tilemaps, input |
| **Babylon.js 8** | 8.x | 3D with a full engine: physics, GUI, inspector, WebXR |
| **PlayCanvas** | engine 2.x | 3D with an editor |
| **Godot 4 web export** | 4.7 | When the game matters more than the site — use a game-studio kit |

## Browser-game architecture (engine-agnostic)
- **Game loop**: fixed-timestep update (simulation) + variable render; `requestAnimationFrame`; pause on `visibilitychange`; clamp `deltaTime`.
- **ECS or a component model** for entities (bitecs/miniplex for TS) beyond ~50 object types; simple classes otherwise.
- **Input**: one abstraction over keyboard/mouse/touch/gamepad (`Gamepad API`, `Pointer Events`); remapping from data.
- **Audio**: `Web Audio API` (graph, source pool), unlocked after a user gesture; `AudioContext.resume()`.
- **Assets**: manifest + preloading with progress; atlases; compressed textures; memory limits on mobile.
- **Saves**: IndexedDB (`idb`) with a versioned schema; server saves via the API, validated server-side.
- **Balance data** in JSON/TS configs, not in code.
- **Budget**: 16.6 ms per frame; draw calls ≤ 100–300 (mobile/desktop); stable JS heap (no growth in the profiler); first frame ≤ 3 s on 4G.

## Multiplayer
- Transport: **WebSocket** (TCP, simple) for turn-based/casual; **WebRTC DataChannel** (UDP-like) for real-time twitch; WebTransport as support grows.
- **Server-authoritative** (Go: `coder/websocket`, tick 20–60 Hz); client prediction + server reconciliation, interpolation for other players; delta snapshots; binary messages (MessagePack/flatbuffers/protobuf), versioned.
- Ready-made: **Colyseus** (Node), Nakama (Go), Photon; the studio default is its own Go server, Colyseus for prototypes.
- Anti-cheat basics: validate every action server-side, rate limits, never trust client coordinates/damage.

## Game-code review checklist
1. No per-frame allocations; 2. dispose on scene change; 3. fixed timestep; 4. engine objects outside framework reactivity; 5. balance data in config; 6. memory/draw calls measured (numbers in the PR); 7. works with touch and without hover.
