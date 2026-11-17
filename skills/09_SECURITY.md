# 09 — Security

**Purpose:** This document records the default security model for the Eclipse ecosystem and the checks that must hold before any feature is considered ready. It is read before shipping or opening new routes, auth flows, or user data handling.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No runtime security implementation is present, so this is the minimum security baseline for an intended multi-repo product rather than a claim of production hardening.

## Threat model

- External clients can access the API, the web app, and the Android app.
- Client applications are untrusted and must not be treated as the enforcement boundary for business rules or secrets.
- User identity and authorization must be validated at the server boundary.
- Secrets, API keys, and auth configuration must be environment-specific and not embedded in source control.

## Authentication and authorization

- Use a named identity provider rather than ad hoc token logic.
- Separate authentication from authorization; the user must be identified before role checks are performed.
- Validate token expiry, issuance context, and scopes before allowing access to protected routes.
- Apply authorization in the API, not only in the UI.

## Secrets handling

- Never commit secrets, private keys, or app credentials.
- Keep environment variables and config files outside source control.
- Ensure local development, staging, and production all use distinct configuration values.

## Input and injection surfaces

- Validate request bodies, query parameters, and file uploads against explicit constraints.
- Treat any external data as untrusted until it is canonicalized and verified.
- Apply parameterized or safe query patterns and avoid ad hoc string SQL or interpolation.

## Debug gates

- Force debug or diagnostic output to be disabled in non-local environments.
- Never expose stack traces, full error payloads, or privileged metadata to end users.
- Keep development-only flags behind explicit environment checks.

## Accepted gaps

- The current repository snapshot has no implemented auth flow, secret management, or runtime config to review. Those must be added and verified before any deployment claim is made.

## Change checklist

Before merging any security-sensitive change:

1. Identify the trust boundary involved.
2. Confirm the auth or authorization rule is enforced server-side.
3. Review whether user data or secrets are exposed in logs or responses.
4. Verify the change is safe in local, staging, and production configuration contexts.
5. Record the rollback or credential rotation path for the change.
