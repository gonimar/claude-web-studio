# Threat Model: [Project]

> Method: STRIDE per surface · Date: · Update whenever a new attack surface appears

## 1. Assets
What we protect (user data, accounts, payments, game progress, infrastructure) and its value.

## 2. System diagram and trust boundaries
Data-flow diagram (mermaid): clients → proxy → services → DB/queues → external APIs; trust boundaries marked.

## 3. Attack surfaces
| Surface | Entry | Authentication | Data |
|---|---|---|---|
(auth, GraphQL/REST API, WebSocket, uploads, webhooks, admin, CI/CD, dependencies, infrastructure)

## 4. Threats (STRIDE)
| ID | Surface | Threat | S/T/R/I/D/E | Likelihood | Impact | Mitigation | Status |
|---|---|---|---|---|---|---|---|

## 5. Assumptions and residual risks

## 6. Verification
Which tests/scans confirm the mitigations (links to audits).
