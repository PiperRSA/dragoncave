# Phase 2 · Observability

## Overview
Enable end-to-end observability across Dragoncave with Loki, Promtail, and Grafana components.

## Scope
- Define log and metrics retention aligned with `docs/SECURITY_BASELINES.md`.
- Automate configuration delivery for Loki/Promtail and dashboards.
- Integrate alert routing into Node-RED or existing notification paths.

## Definition of Done
- [ ] Run `make preflight` successfully.
- [ ] YAML manifests pass `yamllint`.
- [ ] Shell automation passes `shellcheck`.
- [ ] Dockerfiles pass `hadolint` (when present).
- [ ] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
