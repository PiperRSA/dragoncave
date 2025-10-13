# Phase 3 · Automation

## Overview
Operationalise Dragoncave workflows with Node-RED and n8n automations.

## Scope
- Define automation source control and deployment patterns.
- Implement event triggers from observability and infrastructure layers.
- Capture rollback and recovery procedures for critical flows.

## Deliverables
- Node-RED automation stack (`stacks/flows-node-red.yml`) with data persisted under `configs/node-red/`.
- n8n workflow stack (`stacks/jobs-n8n.yml`) secured with Docker secrets.
- Automation runbook `docs/AUTOMATION_GUIDE.md` covering deployment, backups, and troubleshooting.

## Definition of Done
- [x] Run `make preflight` successfully.
- [x] YAML manifests pass `yamllint`.
- [x] Shell automation passes `shellcheck`.
- [x] Dockerfiles pass `hadolint` (when present).
- [x] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
