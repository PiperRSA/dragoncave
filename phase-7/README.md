# Phase 7 · Home & Dev Platform

## Overview
Deliver home automation, secrets management, developer tooling, and object storage with a LAN-first posture.

## Scope
- Operate Home Assistant, Mosquitto, InfluxDB, and Telegraf for telemetry and automations.
- Provide Vaultwarden, Gitea, and MinIO for secure credential storage, code hosting, and backups.
- Ensure selective WAN exposure via Cloudflare Access and Traefik middleware.

## Deliverables
- Home automation stack (`stacks/iot-home-assistant.yml`) with configs for Home Assistant, Mosquitto, and Telegraf.
- Supporting services: Vaultwarden (`stacks/misc-vaultwarden.yml`), Gitea (`stacks/dev-gitea.yml`), MinIO (`stacks/infra-minio.yml`), shared databases (`stacks/data-services.yml`).
- Operator playbook `docs/HOME_DEV_PLATFORM_GUIDE.md` covering onboarding, maintenance, and recovery.

## Definition of Done
- [x] Run `make preflight` successfully.
- [x] YAML manifests pass `yamllint`.
- [x] Shell automation passes `shellcheck`.
- [x] Dockerfiles pass `hadolint` (when present).
- [x] Phase outcomes captured in `docs/PHASES_OVERVIEW.md`.
