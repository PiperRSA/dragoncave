# Phase 1 · Edge Access

## Overview
Deliver secure ingress for Dragoncave by standing up the Cloudflare, Traefik, and Portainer edge stack.

## Scope
- Harden external entrypoints and certificates.
- Configure Portainer for lifecycle management with least privilege.
- Document DNS, certificates, and access paths in `/docs`.

## Definition of Done
- [ ] Run `make preflight` successfully.
- [ ] YAML manifests pass `yamllint`.
- [ ] Shell automation passes `shellcheck`.
- [ ] Dockerfiles pass `hadolint` (when present).
- [ ] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
