# 05 — Debugging Playbook

**Purpose:** This document matches the most common symptoms to likely causes and gives quick commands for investigating them. It is the first place to look when something fails in an environment that is still under construction.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No runtime code or logs are present, so this document is a working playbook for the expected repo layout and failure modes rather than a record of live production incidents.

## Where the logs are

- API: repository-specific log output and structured request logs in the API service
- Web: browser console, network tab, server-side app logs, and access logs
- Android: Logcat, app crash logs, and network tracing
- Specs: changelog, issue notes, and architecture decision records

## Quick commands

```bash
# Check repo health
git -C "c:/Projects/eclipse-ecosystem/eclipse-api" status
git -C "c:/Projects/eclipse-ecosystem/eclipse-web" status
git -C "c:/Projects/eclipse-ecosystem/eclipse-android" status

# Search for config, auth, and route definitions
grep -R "auth\|token\|route\|environment" "c:/Projects/eclipse-ecosystem"
```

## Symptom map

### Symptom: “Repo looks empty or missing implementation”

- Likely causes: branch not created, app repo not checked out, project intentionally scaffold-only.
- Diagnostic shortcut: inspect the directory tree and `git status`; confirm whether there are any tracked source files before assuming a bug.

### Symptom: “Auth works in one client but not another”

- Likely causes: mismatched token handling, different env setup, or missing auth contract review.
- Diagnostic shortcut: compare request headers, redirect URIs, token refresh logic, and environment configuration between the web and Android client.

### Symptom: “The response shape is inconsistent”

- Likely causes: API contract drift, stale client assumptions, or missing validation in the server.
- Diagnostic shortcut: inspect the response envelope, compare the schema in the spec, and verify the clients are parsing the same fields.

### Symptom: “Deployment works in one environment but not the next”

- Likely causes: missing environment config, stale secrets, or release-order mistakes.
- Diagnostic shortcut: compare env variables, app versions, and release tags across environments before debugging code paths.

## Diagnostic order

1. Confirm whether the repo is empty, stale, or in a partial state.
2. Verify the affected contract: API, auth, config, or schema.
3. Check the exact input and output at the boundary where it fails.
4. Compare with the last known good state or tag.
5. Add an inbox note if the behavior is not yet explained by the current code.

This playbook is intentionally explicit about the current scaffold state. As soon as implementation exists, update each symptom with the real messages, causes, and commands that actually appear in the codebase.
