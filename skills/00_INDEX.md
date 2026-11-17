# 00 — Index

**Purpose:** This is the reading order and maintenance map for the Eclipse ecosystem skills set. Use it to orient new contributors and to record the last verified state of the repository.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. The code wins; the app repositories are empty aside from Git metadata, and the specification folder contains only planning placeholders.

## Reading order by task

| Task                           | Start here            | Then read                                                     |
| ------------------------------ | --------------------- | ------------------------------------------------------------- |
| New contributor onboarding     | 00_INDEX              | 01_ARCHITECTURE, 02_PROJECT_STRUCTURE, 14_DEVELOPER_WORKFLOWS |
| Change impact review           | 04_CHANGE_RULES       | 05_DEBUGGING_PLAYBOOK, 06_FAILURE_STORIES                     |
| Feature design                 | 01_ARCHITECTURE       | 07_DATABASE, 08_API, 09_SECURITY                              |
| Release work                   | 10_DEPLOYMENT         | 11_TESTING, 12_PERFORMANCE                                    |
| Dependency or policy decisions | 13_DEPENDENCIES       | 16_ENGINEERING_PRINCIPLES                                     |
| Incident response              | 05_DEBUGGING_PLAYBOOK | 06_FAILURE_STORIES, 15_KNOWN_LIMITATIONS                      |

## Skill document inventory

| File                         | Topic                                    | Last verified |
| ---------------------------- | ---------------------------------------- | ------------- |
| 00_INDEX.md                  | Reading order and index                  | 2026-11-17    |
| INBOX.md                     | Unverified notes and proposed additions  | 2026-11-17    |
| 01_ARCHITECTURE.md           | System model and boundaries              | 2026-11-17    |
| 02_PROJECT_STRUCTURE.md      | Repo layout and code ownership           | 2026-11-17    |
| 03_CODE_STYLE.md             | Naming, comments, and coding conventions | 2026-11-17    |
| 04_CHANGE_RULES.md           | Lockstep changes and review gates        | 2026-11-17    |
| 05_DEBUGGING_PLAYBOOK.md     | Symptom-driven investigation             | 2026-11-17    |
| 06_FAILURE_STORIES.md        | Known failure patterns and lessons       | 2026-11-17    |
| 07_DATABASE.md               | Schema and integrity rules               | 2026-11-17    |
| 08_API.md                    | Route and contract conventions           | 2026-11-17    |
| 09_SECURITY.md               | Trust boundaries and secrets handling    | 2026-11-17    |
| 10_DEPLOYMENT.md             | Release flow and service deployment      | 2026-11-17    |
| 11_TESTING.md                | Confidence model and validation          | 2026-11-17    |
| 12_PERFORMANCE.md            | Limits and hot paths                     | 2026-11-17    |
| 13_DEPENDENCIES.md           | Policy and version guidance              | 2026-11-17    |
| 14_DEVELOPER_WORKFLOWS.md    | Common day-to-day tasks                  | 2026-11-17    |
| 15_KNOWN_LIMITATIONS.md      | Current gaps and risks                   | 2026-11-17    |
| 16_ENGINEERING_PRINCIPLES.md | Guiding rules for the team               | 2026-11-17    |

## How to contribute

- Add a short note to `INBOX.md` when you discover a missing rule or a discrepancy.
- Prefer updating the relevant numbered document over creating a parallel document.
- Keep evidence tied to code, config, or repo state; if no code exists, label the document as scaffold-level guidance.
- Mark anything unverified with a clear note instead of presenting it as fact.

## Changelog

### 2026-11-17

- Created the initial Eclipse skills baseline for the current repo state.
- Documented the repo as scaffold-only: the app repos have no committed implementation files yet.
- Added the full skills catalog and the index so the project can grow without losing context.

---

This index is intentionally conservative: it reflects only the repository state that is currently visible. When actual app code lands, these documents should be refreshed and narrowed to verified implementation details.
