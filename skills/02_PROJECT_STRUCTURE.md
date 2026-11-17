# 02 — Project Structure

**Purpose:** This document defines where code should live in the Eclipse ecosystem and what belongs in each repository. It is the map for new code and the rulebook for what must not be added to the wrong layer.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. The actual app code is not present, so this is a structural baseline rather than a verified implementation tree.

## Intended repository layout

```text
 eclipse-ecosystem/
 ├─ AGENTS.md
 ├─ handoff.md
 ├─ eclipse-api/
 │  ├─ AGENTS.md
 │  └─ ... backend source, migrations, tests, config
 ├─ eclipse-web/
 │  ├─ AGENTS.md
 │  └─ ... browser app source, config, tests
 ├─ eclipse-android/
 │  ├─ AGENTS.md
 │  └─ ... Android app source, config, tests
 ├─ eclipse-specs/
 │  ├─ AGENTS.md (if added later)
 │  ├─ business-logic-v1.0.md
 │  ├─ git-guidelines.md
 │  ├─ sense-making.md
 │  └─ skills/
 │     ├─ 00_INDEX.md
 │     ├─ INBOX.md
 │     └─ ... numbered skills docs
 └─ ...
```

## Where new code goes

- Add backend code in [eclipse-api](../eclipse-api).
- Add browser UI logic in [eclipse-web](../eclipse-web).
- Add Android code in [eclipse-android](../eclipse-android).
- Add product, contract, security, and business documentation in [eclipse-specs](../).

## Must not go here

- Do not place web-only UI code in the API repo.
- Do not place API business rules in the Android or web clients.
- Do not write app logic into the spec files unless it is explicitly a decision record or a contract note.
- Do not add hidden cross-repo dependencies that bypass the API contract.

## Naming conventions that matter

- Prefer domain names with clear product meaning over generic names such as `core`, `util`, or `shared` unless the code truly spans all clients.
- Keep repository-specific code names aligned with product features and user flows.
- Use feature-based folders and files that can be traced back to the requirement or decision record.
- Preserve a one-to-one relationship between a document, a contract, and a runtime implementation so an engineer can find the source of truth quickly.

## Current repo state

The tree above is the intended state. The currently visible working tree contains only placeholder specs and empty component repos, so no implementation-specific path names are yet proven. When real code appears, this document should be updated to reflect the actual package and folder boundaries.
