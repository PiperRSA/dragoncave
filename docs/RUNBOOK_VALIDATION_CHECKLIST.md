# Runbook Validation Checklist

Use this checklist when executing the Dragoncave runbooks on the Raspberry Pi. Tick items as you validate each procedure to keep documentation accurate and actionable.

## Before You Start
- [ ] Update the repository on the Pi: `./scripts/pi_sync_main.sh`.
- [ ] Confirm `make preflight` passes locally.
- [ ] Ensure Cloudflare Access policies include your operator identity.
- [ ] Verify secrets listed in `docs/SECRETS_TEMPLATE.md` exist with correct ownership/permissions.
- [ ] Confirm `/opt/dragoncave/.env.dragoncave` defines `PI_HOST_IP`, `HOARD1_ROOT`, `HOARD2_ROOT`, and `VAULT3_ROOT` with the correct mount points.

## Phase 1 · Edge Access (`docs/EDGE_ACCESS_GUIDE.md`)
- [ ] Confirm `edge`, `core`, `dns` networks exist (`docker network ls`).
- [ ] Run each deployment command in the guide and observe successful container starts.
- [ ] Access Traefik dashboard via LAN and Cloudflare Access.
- [ ] Validate smoke tests print 200/302 for Traefik, Portainer, whoami.
- [ ] Update the runbook with any command/output differences noticed during deployment.

## Phase 2 · Observability (`docs/OBSERVABILITY_GUIDE.md`)
- [ ] Create directories for Loki, Promtail, Grafana as documented.
- [ ] Deploy `stacks/obs-logs.yml` and verify containers healthy in Portainer.
- [ ] Deploy `stacks/obs-exporters.yml`; confirm `cadvisor` and `node-exporter` running (enable `smart-exporter` only if disks support SMART).
- [ ] Add Loki data source in Grafana and import baseline dashboards.
- [ ] Confirm Promtail streams Traefik logs into Grafana Explore.
- [ ] Validate metrics scraping (Prometheus or Telegraf) against `cadvisor`, `node-exporter`, and optional SMART endpoints; update dashboards accordingly.
- [ ] Note retention/alerting tweaks back into the guide.

## Phase 3 · Automation (`docs/AUTOMATION_GUIDE.md`)
- [ ] Prepare Node-RED and n8n config folders; set N8N secrets.
- [ ] Deploy automation stacks and confirm access via browser.
- [ ] Export a sample flow/workflow into Git for backup.
- [ ] Record any custom environment variables or credential handling in the guide.

## Phase 4 · Data Services (`docs/DATA_SERVICES_GUIDE.md`)
- [ ] Deploy shared database stack before dependants.
- [ ] Start Meilisearch and Pi-hole; test API and DNS resolution.
- [ ] Update LAN clients/DHCP to use Pi-hole; verify queries appear in dashboard.
- [ ] Log backup commands used for Postgres/MariaDB/Redis in the runbook.

## Phase 5 · Knowledge & Productivity (`docs/KNOWLEDGE_GUIDE.md`)
- [ ] Deploy Nextcloud and complete web installer.
- [ ] Deploy Paperless-ngx; ingest a sample document to validate OCR.
- [ ] Configure nightly backups for databases and data directories.
- [ ] Capture any SMTP or external storage configuration steps.

## Phase 6 · Media & Workflows (`docs/MEDIA_WORKFLOWS_GUIDE.md`)
- [ ] Deploy Immich stack and create admin account.
- [ ] Integrate Meilisearch and verify search results populate.
- [ ] Set up automation trigger (Node-RED/n8n) for new uploads.
- [ ] Document storage usage metrics and scaling notes observed.

## Phase 7 · Home & Dev Platform (`docs/HOME_DEV_PLATFORM_GUIDE.md`)
- [ ] Deploy Home Assistant stack; onboard devices and set MQTT creds.
- [ ] Provision Vaultwarden admin account and import vault.
- [ ] Initialise Gitea organization and repositories.
- [ ] Create MinIO buckets and test S3 access with `mc`.
- [ ] Log any additional environment variables, USB mappings, or integrations needed.

## After Validation
- [ ] Update `CHANGELOG.md` with runbook verification notes and dated entries.
- [ ] Commit documentation changes and push to remote.
- [ ] Open/refresh dashboards in Grafana and Portainer to confirm observability coverage.

Repeat this checklist after significant infrastructure updates or new integrations to keep runbooks reliable.
