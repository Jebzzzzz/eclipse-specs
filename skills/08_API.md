# 08 — API

**Purpose:** This document defines the API conventions and safety rules for the Eclipse service layer. It explains how to add new endpoints, version them, validate input, and keep the contract consistent across the web and Android clients.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. No API implementation is present, so this is a baseline contract model for future implementation rather than a verified route inventory.

## Response envelope

Use a consistent response shape for every API response, for example:

```json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": {
    "requestId": "...",
    "timestamp": "..."
  }
}
```

- `success` indicates whether the request completed without an application-level failure.
- `data` holds the requested payload or resource state.
- `error` contains a machine-readable error code and a safe message.
- `meta` provides operational context such as run id and request timestamp.

## Route inventory

At the current repo state, there is no verified route inventory. The expected pattern is:

- `/auth/*` for identity and session operations
- `/users/*` for profile and account management
- `/<domain>/*` for feature-specific resources
- `/health` or equivalent for service health checks

## How to add an endpoint

1. Confirm the product requirement in the specs.
2. Add the route contract and validation rules in the API repo.
3. Update the web and Android clients that use it.
4. Document the auth and permission requirements.
5. Add a failing or smoke test before final merge.

## Validation rules

- Validate every input on the server, even if the client already checks it.
- Reject empty, malformed, or unauthorized requests before touching persistence.
- Return stable error codes so client apps can handle them consistently.
- Keep business rules server-side and never in a client view model.

## Versioning and compatibility

- Prefer explicit versioning for routes or response contracts where the client surface is not fully controlled.
- Keep backward compatibility in mind when changing fields or status values.
- If a response shape changes, update the docs and the client at the same time.

## Common mistakes

- Accepting data that is only partially validated.
- Treating UI validation as a security boundary.
- Returning raw exceptions or stack traces to clients.
- Mixing business workflow logic into route handlers without clear domain boundaries.

This API baseline should be tightened to the real implementation once the backend repo contains route and handler code.
