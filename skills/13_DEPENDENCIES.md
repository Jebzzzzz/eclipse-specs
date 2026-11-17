# 13 — Dependencies

**Purpose:** This document describes the dependency policy and the kinds of third-party choices that should be deliberate, reviewable, and easy to retire when they stop matching the project’s needs.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No code or dependency manifests are present, so this is the policy baseline that will be tightened when the app repos are filled in.

## Policy

- Prefer dependencies that solve a well-understood problem and have clear upgrade paths.
- Avoid adding libraries that clone functionality already provided by the platform or common framework tooling.
- Document why a dependency exists and what breaks if it is removed.
- Keep upgrades small and reviewable; large migrations should be treated as feature work.

## Dependency categories

| Dependency type           | Choice rule                                                            |
| ------------------------- | ---------------------------------------------------------------------- |
| Auth provider             | Must support the team’s security model and work across web and Android |
| API client                | Prefer a stable contract and clear versioning                          |
| Network or HTTP libraries | Keep them small, explicit, and easy to reason about                    |
| UI frameworks             | Choose only what is needed for the product and team velocity           |
| Observability tooling     | Add only if logs and metrics are actually used in debugging            |

## Upgrade traps

- Breaking auth semantics or token handling during library upgrades
- API client changes that silently reorder or rename fields
- UI framework updates that alter form or navigation behavior without a test plan

## Deliberate rejections

- Do not add broad “do everything” libraries when the product needs a narrow, explicit solution.
- Do not add hidden runtime tools that increase attack surface without operational value.
- Do not pull in a dependency solely because it is trendy; it must solve a real project cost.

This policy should be updated with the actual dependency inventory after the app repos are populated.
