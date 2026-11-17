# 12 — Performance

**Purpose:** This document captures the performance guardrails expected for the Eclipse ecosystem and the kinds of hot paths that will deserve measurement once the app is implemented.

**Confidence note:** Verified against the current repo scaffold on 2026-11-17. The repo contains no runtime code, so the performance guidance is intentionally minimal and framed as a future operating model.

## Hard limits

- Web and mobile features should not make unnecessary round trips.
- API request volume should be bounded by explicit auth, validation, and pagination rules.
- Large list or query operations should be paginated or filtered before delivery.

## Hot paths

- Authentication and token refresh
- User lookup and permission checks
- Any list view that fetches large records without pagination
- Write-heavy endpoints that might trigger multiple persistence actions

## Deliberate inefficiencies to leave alone

- Broad joins or large unbounded queries in the API
- Loading complete datasets into the UI when a paged view is enough
- Re-running expensive permission checks on every render cycle

## Expensive operations

- Large object graph reads
- Network calls repeated on view re-render
- Unbounded search or text scanning on large data sets

## Profiling approach

- Measure on the API boundary first; the backend is the likely source of latency.
- Check browser or Android network traces after backend behavior is understood.
- Use targeted metrics for request time, payload size, and number of round trips.

This document should be replaced with measured operational limits after the actual application code is introduced.
