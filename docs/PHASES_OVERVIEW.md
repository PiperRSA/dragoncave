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

## Phase 5 · Knowledge & Productivity
- Roll out Nextcloud and Paperless with dedicated database backends.
- Protect document services with Cloudflare Access and encrypted backups.
- [ ] `docker compose -f stacks/files-nextcloud.yml config`
- [ ] `docker compose -f stacks/docs-paperless.yml config`

## Phase 6 · Media & Workflows
- Enable Immich, Node-RED, n8n, and Meilisearch for media and automation needs.
- Integrate alerting and search services with observability outputs.
- [ ] `docker compose -f stacks/photos-immich.yml config`
- [ ] `docker compose -f stacks/flows-node-red.yml config`
- [ ] `docker compose -f stacks/jobs-n8n.yml config`
- [ ] `docker compose -f stacks/search-meili.yml config`

## Phase 7 · Home & Dev Platform
- Provide Home Assistant, MQTT, Vaultwarden, Gitea, MinIO, and shared databases.
- Ensure LAN-first posture with selective WAN exposure via Access.
- [ ] `docker compose -f stacks/iot-home-assistant.yml config`
- [ ] `docker compose -f stacks/misc-vaultwarden.yml config`
- [ ] `docker compose -f stacks/dev-gitea.yml config`
- [ ] `docker compose -f stacks/infra-minio.yml config`
- [ ] `docker compose -f stacks/data-services.yml config`
