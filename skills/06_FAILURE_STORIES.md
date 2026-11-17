# 06 — Failure Stories

**Purpose:** This file records the lessons that come from failed assumptions, mis-scoped changes, and repository drift. It is meant to teach the next engineer how to recognize a pattern before it becomes a production incident.

**Confidence note:** Verified against the repo scaffold on 2026-11-17. Because the live app code is not present, the failure stories here are drawn from structural risks visible in the workspace rather than from production incidents.

## 1. The repo looked “ready” but was not implemented

- **What happened:** The workspace contains JavaScript or mobile app repos and specs documentation, but the actual application code is absent. A newcomer could easily assume implementation was in progress or completed when it was not.
- **Why:** The repository layout created the illusion of a complete system without the code, tests, or runtime config to support it.
- **How it was found:** The repo was inspected directly and each app folder was checked for tracked source files and Git history. Each repo was effectively a project skeleton with Git metadata only.
- **Fix:** Treat the repo as a scaffold until source files and validated build steps exist. Keep the docs explicit about what is confirmed versus implied.
- **Lesson:** The codebase must be grounded in tracked source files; folder names and templates are not implementation evidence.

## 2. Placeholder product details create false architecture certainty

- **What happened:** Business logic placeholders such as `<Platform>` and `<Team Name>` were left in the specs documents without actual product details.
- **Why:** The architecture and team workflows were inferred from the intended shape rather than from the real product requirements.
- **How it was found:** The specification document was read as a template and compared against the actual repo state; it did not contain real product details or user flows.
- **Fix:** Replace placeholders with verified business facts, or clearly label the document as an outline. Avoid treating templates as design decisions.
- **Lesson:** A missing requirement is not a requirement; it is a risk.

## Confidence and caution

These stories are intentionally low-confidence historical notes about the current repository state. When implementation code is introduced, add real failure stories tied to actual incidents, commit hashes, and recovery actions.
