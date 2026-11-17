# 16 — Engineering Principles

**Purpose:** This file records the principles that explain the patterns and guardrails in the rest of the skills set. It provides a durable, quotable standard that can survive changes in team membership.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. This is a principle baseline derived from the visible repo state and the handoff instructions, not a claim that the app has been built or deployed.

## 1. The code wins

A document is only useful if it describes reality, not intent. If the code and the document disagree, trust the code and fix the document.

## 2. The repo boundary matters

A system split across API, web, Android, and specs is only healthy when each repo owns a clear layer. Hidden cross-repo logic creates drift and security risk.

## 3. Lockstep changes must be reviewed together

A feature is not complete when one repo changes and the others are stale. Auth, schema, client calls, and deployment config must move together.

## 4. Silent failures are the real risk

Fallbacks, hidden defaults, and undocumented assumptions become incidents later. If a path can silently fail, the team must make the failure visible.

## 5. Trust the contract, not the UI

The client can show a success state even when the server rejected or altered the request. Validations and policy checks must happen where the canonical state lives.

## 6. Evidence beats optimism

A folder tree or a design doc is not proof of a working product. Source files, tests, config, and smoke checks are the evidence that matters.

## 7. Keep the system legible

A team that can explain what each module owns, which data is canonical, and which contract is authoritative will recover faster from mistakes and change faster without chaos.

> trust the code over any document, including this one

These principles are intentionally short and durable. They should remain stable even as the app grows, because they encode the team’s operating model rather than a specific technology stack.
