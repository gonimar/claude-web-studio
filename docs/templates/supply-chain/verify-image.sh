#!/usr/bin/env bash
# Verifies the keyless cosign signature of an image by digest before a rollout (SC-09).
# Reference: .claude/docs/stack-reference/supply-chain.md § Artifact signing and verification.
# Usage: verify-image.sh ghcr.io/<owner>/<image>@sha256:<digest> [<owner>/<repo>] [<workflow file>] [<ref pattern>]
#   The identity is pinned to the release workflow and the tag ref, never to the repository alone.
#   Exit 0 = signature verified for that identity and issuer; anything else blocks the deploy.
set -euo pipefail

image="${1:?image reference with @sha256:<digest>}"
repo="${2:-${SUPPLY_CHAIN_REPO:?owner/repo (arg 2 or SUPPLY_CHAIN_REPO)}}"
workflow="${3:-${SUPPLY_CHAIN_WORKFLOW:-release.yml}}"
ref_pattern="${4:-${SUPPLY_CHAIN_REF:-refs/tags/v}}"
issuer="https://token.actions.githubusercontent.com"

case "$image" in
  *@sha256:*) ;;
  *) echo "refusing to verify by tag — pass the image by digest (…@sha256:…)" >&2; exit 2 ;;
esac
command -v cosign >/dev/null || { echo "cosign not installed (https://github.com/sigstore/cosign/releases)" >&2; exit 2; }

identity_re="^https://github.com/${repo}/\.github/workflows/${workflow}@${ref_pattern}"

cosign verify "$image" \
  --certificate-oidc-issuer "$issuer" \
  --certificate-identity-regexp "$identity_re" \
  --output text
echo "verified: ${image} signed by ${repo}/.github/workflows/${workflow} (${issuer})"

# Optional: GitHub provenance attestation, when the repository plan produces one (SC-10).
if [ "${SUPPLY_CHAIN_ATTEST:-0}" = "1" ] && command -v gh >/dev/null; then
  gh attestation verify "oci://${image}" -R "$repo" --bundle-from-oci
fi
