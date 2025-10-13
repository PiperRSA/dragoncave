# Phase 4 · Data Services

## Overview
Deliver data-centric services including Pi-hole, Meilisearch, and supporting storage requirements.

## Scope
- Harden Pi-hole and Meilisearch deployments with network policies.
- Establish backup, restore, and upgrade procedures for stateful workloads.
- Align data retention with the security baselines in `/docs`.

## Deliverables
- DNS stack (`stacks/dns-pihole.yml`) with configs under `configs/pihole/`.
- Search stack (`stacks/search-meili.yml`) guarded by Traefik and secrets.
- Shared database bundle (`stacks/data-services.yml`) for Postgres, MariaDB, Redis.
- Operations runbook `docs/DATA_SERVICES_GUIDE.md`.

## Definition of Done
- [x] Run `make preflight` successfully.
- [x] YAML manifests pass `yamllint`.
- [x] Shell automation passes `shellcheck`.
- [x] Dockerfiles pass `hadolint` (when present).
- [x] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
