# Phase 1 · Edge Access

## Overview
Deliver secure ingress for Dragoncave by standing up the Cloudflare, Traefik, and Portainer edge stack.

## Scope
- Harden external entrypoints and certificates.
- Configure Portainer for lifecycle management with least privilege.
- Document DNS, certificates, and access paths in `/docs`.

## Deliverables
- Cloudflare named tunnel and DNS routing (`stacks/tunnel-cloudflared.yml`, `configs/cloudflared/config.yml`).
- Traefik v3 edge proxy with BasicAuth, ACME DNS-01, and middleware (`stacks/edge-traefik.yml`, `configs/traefik/dynamic.yml`, `configs/traefik/tls.yml`).
- Docker socket proxy for controlled API access (`stacks/sec-docker-socket-proxy.yml`).
- Portainer behind Traefik with shared BasicAuth (`stacks/portainer.yml`).
- Operator runbook: `docs/EDGE_ACCESS_GUIDE.md`.

## Definition of Done
- [x] Run `make preflight` successfully.
- [x] YAML manifests pass `yamllint`.
- [x] Shell automation passes `shellcheck`.
- [x] Dockerfiles pass `hadolint` (when present).
- [x] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
