---
paths: ["**/game/**", "**/*.glsl", "**/*.wgsl", "**/*.vert", "**/*.frag", "**/three/**", "**/scenes/**"]
---
# Game code rules
- Fixed timestep for the simulation, interpolated rendering; pause on `visibilitychange`; clamp `deltaTime`.
- No per-frame allocations: reuse vectors/buffers; object pools.
- `dispose()` geometries/materials/textures on scene change; check `renderer.info`.
- Engine objects live outside framework reactivity (`markRaw`, a service outside change detection).
- Balance data and parameters in configs (JSON/TS), not code; versioned save schema.
- Budget numbers (frame ms, draw calls, memory) in the PR description.
- The server is authoritative; client values are never trusted; messages are versioned.
- Shaders: TSL on the WebGPU path; GLSL only for the WebGL fallback; no magic numbers, uniforms documented.
- Reference: `.claude/docs/stack-reference/threejs-webgames.md`.
