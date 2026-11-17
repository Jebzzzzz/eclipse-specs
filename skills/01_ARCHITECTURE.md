# 01 — Architecture

**Purpose:** This document describes the intended architecture of the Eclipse ecosystem and the guardrails for how the API, web app, Android app, and specs repository should interact. It is read first because it explains the system model and the boundaries that keep teams from creating hidden couplings.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. The implementation layer is not present, so this is a scaffold-level architecture model rather than a production architecture claim.

## One-paragraph model

The Eclipse ecosystem is intended to be a multi-repository product family with a shared specification layer, a backend API, a web client, and an Android client. The system should keep product decisions in the business logic and specs repos, keep runtime logic in the API and clients, and avoid any cross-repo code sharing that bypasses the published contracts. The current repository snapshot shows the intended structure but not the actual implemented application, so the architecture below is a baseline for future implementation, not a statement that the application is live.

## Components and ownership

| Component                             | Owns                                                                   | Must not own                                 |
| ------------------------------------- | ---------------------------------------------------------------------- | -------------------------------------------- |
| [eclipse-specs](../)                  | product requirements, roadmap, critical decisions, schema change notes | runtime logic or app state                   |
| [eclipse-api](../eclipse-api)         | API contracts, auth, business workflows, persistence access            | UI rendering or mobile-specific logic        |
| [eclipse-web](../eclipse-web)         | browser UX, client-side validation, user flows                         | server-side business logic beyond thin calls |
| [eclipse-android](../eclipse-android) | mobile UI and local state, Android-specific integrations               | database migrations or API policy decisions  |

## End-to-end data flow

1. A user enters a workflow in the web or Android client.
2. The client validates obvious input and calls the API through a versioned contract.
3. The API enforces auth, authorization, and validation rules before reading or writing data.
4. The persistence layer stores canonical state, and the API returns a stable response envelope.
5. The UI consumes the response and updates local state without inventing new server-side rules.

## Hard boundaries

- The API is the source of truth for business rules and persisted state; clients do not own canonical logic.
- The web and Android app should not duplicate validation rules that matter to the server.
- Specs should describe the contract, not hide it in implementation details.
- Infrastructure and deployment behavior should be documented in deployment docs, not silently embedded in app code.

## Decision records

### Decision: Keep the repo split explicit (2026-11-17, scaffold baseline)

**Status:** proposed
**Context / Choice / Alternatives / Consequences:** The repo is intentionally split into app-specific repos plus a shared specs repo. The alternative is a monorepo or mixed code ownership, which would blur boundaries and create hidden dependencies. The consequence is that cross-team features require explicit contract review and release coordination.

## Ranked debt register

1. Product details are placeholders rather than verified requirements.
2. The app repos have no committed source code or runtime configuration.
3. No CI, deployment, testing, or database migrations are visible yet.
4. No actual auth, schema, or route contracts are implemented or verified.

This document should be revisited after implementation code exists. Until then, treat it as a boundary model waiting for evidence.
