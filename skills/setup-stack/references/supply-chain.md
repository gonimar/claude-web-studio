# Supply chain — read from Phase 2 step 7, after observability

Reference: `.claude/docs/stack-reference/supply-chain.md` (the studio defaults, the release job template, the checklist `SC-01…SC-12`). The answer fills the `Supply chain` block of technical-preferences: `sbom_tool`, `signing`, `provenance`, `update_bot`, `release_age` — never the bracketed template line, which `/deploy` and `/release-checklist` cannot read.

- **Supply chain**, one `AskUserQuestion`, recommendation first:
  - **studio default** (Recommended when the project ships a release image): `sbom_tool: syft` (CycloneDX JSON, attached to the release), `signing: cosign keyless` (GitHub OIDC, verified by digest before deploy — `docs/templates/supply-chain/verify-image.sh`), `provenance: actions/attest` (SLSA Build L2; private repositories need GitHub Enterprise Cloud for attestations — otherwise `provenance: none — plan`), `update_bot: renovate` (`docs/templates/supply-chain/renovate.json`), `release_age: 7 days`.
  - **no release image** (a static site, a library, a tool without a container): `sbom_tool: none — no image`, `signing: none — no image`, `provenance: none — no image`; the update bot and the release age are still asked and recorded.
  - **custom**: the owner names what differs (a key-based signing, Dependabot, another SBOM tool); every field gets a value and the reason.
- Every `none` carries its reason after the dash — `/release-checklist` turns a reasoned `none` into a ⚠ line, an unreasoned one into a question.
- `--quick`: takes the studio default (or `no release image` when the deploy target is `none`) without asking.
