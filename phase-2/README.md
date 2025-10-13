# Phase 2 · Observability

## Overview
Enable end-to-end observability across Dragoncave with Loki, Promtail, and Grafana components.

## Scope
- Define log and metrics retention aligned with `docs/SECURITY_BASELINES.md`.
- Automate configuration delivery for Loki/Promtail and dashboards.
- Integrate alert routing into Node-RED or existing notification paths.

## Deliverables
- Observability stack compose file (`stacks/obs-logs.yml`) wired to `edge`/`core` networks.
- Loki configuration stored at `configs/loki/local-config.yaml` with 30-day retention.
- Promtail configuration at `configs/promtail/config.yml` using the Docker socket proxy `dprox`.
- Grafana persistent data directory (`configs/grafana/`) with operator notes.
- Metrics exporters stack (`stacks/obs-exporters.yml`) for cadvisor, node-exporter, and optional SMART telemetry.
- Runbook documenting deployment and operations: `docs/OBSERVABILITY_GUIDE.md`.

## Definition of Done
- [x] Run `make preflight` successfully.
- [x] YAML manifests pass `yamllint`.
- [x] Shell automation passes `shellcheck`.
- [x] Dockerfiles pass `hadolint` (when present).
- [x] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
