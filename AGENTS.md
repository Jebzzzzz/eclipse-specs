
# Eclipse Specifications - Agent Instructions

## Purpose
This repository contains the product ecosystem specifications for Eclipse / OJT Chronicle.

It serves as the central reference for product requirements, system behavior, architecture, data models, API contracts, and compliance requirements.

## Responsibilities

- Maintain product requirements and feature specifications.
- Document user roles, permissions, and workflows.
- Maintain system architecture and technical documentation.
- Document database entities, relationships, and constraints.
- Define API contracts and expected request/response behavior.
- Document security, privacy, and regulatory compliance requirements.
- Track planned, approved, and implemented features.

## Documentation Rules

1. Keep specifications clear, structured, and implementation-independent where appropriate.
2. Use consistent terminology throughout the repository.
3. Distinguish between MVP features, planned features, and out-of-scope features.
4. Do not document proposed behavior as an approved requirement.
5. Do not silently change existing business rules.
6. Identify assumptions and unresolved decisions explicitly.
7. Keep diagrams and data models synchronized with written specifications.

## Product Scope

The initial product focuses on individual OJT documentation.

Core capabilities include:
- Recording internship activities and working hours.
- Uploading supporting screenshots and evidence.
- Writing original activity descriptions.
- Requesting AI-assisted grammar and clarity improvements.
- Preserving original and enhanced descriptions.
- Maintaining revision history and timestamps.

Manuscript organization and document export must be treated according to their approved implementation phase. Do not assume planned features are already part of the MVP.

## Change Management

When updating a specification:
- Explain what changed and why.
- Identify affected repositories.
- Identify any changes to database structures or API contracts.
- Highlight potential breaking changes.
- Keep related diagrams and documentation updated.

## Restrictions

- Do not implement application features in this repository.
- Do not introduce undocumented requirements.
- Do not overwrite existing decisions without documenting the change.
- Do not include real credentials, private student data, or sensitive production information.
