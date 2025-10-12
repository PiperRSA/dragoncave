# Phase 4 · Data Services

## Overview
Deliver data-centric services including Pi-hole, Meilisearch, and supporting storage requirements.

## Scope
- Harden Pi-hole and Meilisearch deployments with network policies.
- Establish backup, restore, and upgrade procedures for stateful workloads.
- Align data retention with the security baselines in `/docs`.

## Definition of Done
- [ ] Run `make preflight` successfully.
- [ ] YAML manifests pass `yamllint`.
- [ ] Shell automation passes `shellcheck`.
- [ ] Dockerfiles pass `hadolint` (when present).
- [ ] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
