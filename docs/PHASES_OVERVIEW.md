# Dragoncave Delivery Phases

This guide describes the phased rollout for the Dragoncave homelab. Each phase builds on the previous one and must satisfy the shared Definition of Done diagnostics before moving forward.

## Shared Definition of Done
- [ ] `make preflight` completes successfully.
- [ ] YAML manifests pass `yamllint`.
- [ ] Shell automation passes `shellcheck`.
- [ ] Dockerfiles pass `hadolint` (when present).

## Phase 0 · Foundations
- Establish baseline documentation for hardware, network topology, and security controls.
- Capture naming conventions and access policies aligned with homelab requirements.

## Phase 1 · Edge Access
- Deploy and secure Cloudflare, Traefik, and Portainer as the external entrypoint stack.
- Document certificate workflows, access controls, and recovery steps.

## Phase 2 · Observability
- Provide logging and metrics coverage with Loki, Promtail, and Grafana.
- Define alert routing and retention strategies consistent with security baselines.

## Phase 3 · Automation
- Implement automation pipelines using Node-RED and n8n.
- Govern workflow lifecycle, versioning, and rollback paths.

## Phase 4 · Data Services
- Deliver Pi-hole, Meilisearch, and supporting data services.
- Define backup, restore, and lifecycle policies for stateful components.
