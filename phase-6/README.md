# Phase 6 · Media & Workflows

## Overview
Enable media management and automation integrations with Immich, Node-RED, n8n, and Meilisearch.

## Scope
- Deploy Immich with dedicated Postgres/Redis backends.
- Integrate media workflows with existing automation services.
- Extend search capabilities through Meilisearch ingestion.

## Deliverables
- Immich stack (`stacks/photos-immich.yml`) with storage mapped under `${HOARD2_ROOT}/immich` and Postgres persisted on `${HOARD1_ROOT}/databases/postgres/immich`.
- Automation integrations via Node-RED/n8n referencing `docs/AUTOMATION_GUIDE.md`.
- Media runbook `docs/MEDIA_WORKFLOWS_GUIDE.md` documenting deployment, storage planning, and monitoring.

## Definition of Done
- [x] Run `make preflight` successfully.
- [x] YAML manifests pass `yamllint`.
- [x] Shell automation passes `shellcheck`.
- [x] Dockerfiles pass `hadolint` (when present).
- [x] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
