# Phase 5 · Knowledge & Productivity

## Overview
Roll out document and knowledge platforms with resilient storage and access controls.

## Scope
- Deploy Nextcloud for collaborative storage with PostgreSQL backend.
- Stand up Paperless-ngx for document capture, OCR, and tagging.
- Integrate Cloudflare Access and backup workflows to protect user data.

## Deliverables
- Nextcloud stack (`stacks/files-nextcloud.yml`) with data volumes and secrets.
- Paperless-ngx stack (`stacks/docs-paperless.yml`) including Redis/Postgres dependencies.
- Operator runbook `docs/KNOWLEDGE_GUIDE.md` covering setup, backups, and troubleshooting.

## Definition of Done
- [x] Run `make preflight` successfully.
- [x] YAML manifests pass `yamllint`.
- [x] Shell automation passes `shellcheck`.
- [x] Dockerfiles pass `hadolint` (when present).
- [x] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
