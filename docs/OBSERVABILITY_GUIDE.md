# Observability Guide (Phase 2)

Phase 2 introduces a centralised observability stack with Grafana, Loki, and Promtail. This guide covers configuration, deployment, and operations.

## Components & Source of Truth
| Component | Stack / Config | Responsibility |
| --- | --- | --- |
| Loki (`loki`) | `stacks/obs-logs.yml`, `configs/loki/local-config.yaml` | Stores log streams with on-disk retention. |
| Promtail (`promtail`) | `stacks/obs-logs.yml`, `configs/promtail/config.yml` | Scrapes container and host logs, forwards to Loki. |
| Grafana (`grafana`) | `stacks/obs-logs.yml`, `configs/grafana/` | Visualises logs/metrics and hosts dashboards. |
| Exporters (`cadvisor`, `node-exporter`, `smart-exporter`) | `stacks/obs-exporters.yml` | Expose container, host, and disk SMART metrics. |
| Smoke tests | `scripts/smoke-tests.sh` | Confirms `https://obs.hexwyrm.com` responds with 200/302. |

## Prerequisites
- Phase 1 edge stack operational (Cloudflare Tunnel, Traefik, Portainer).
- Secrets:
  - `/opt/dragoncave/secrets/GRAFANA_ADMIN_PASS` (uid:gid 1000:1000, mode 0400) for Grafana admin.
- Directories on the Raspberry Pi:
  ```bash
  sudo install -d -m 0755 -o 1000 -g 1000 \
    /opt/dragoncave/configs/loki \
    /opt/dragoncave/configs/promtail \
    /opt/dragoncave/configs/grafana

  sudo install -d -m 0755 -o 1000 -g 1000 \
    ${HOARD1_ROOT}/observability/loki \
    ${HOARD1_ROOT}/observability/grafana \
    ${HOARD1_ROOT}/observability/kuma
  ```
  Run `export $(grep -v '^#' /opt/dragoncave/.env.dragoncave | xargs)` beforehand or substitute the absolute paths (e.g. `/srv/hoard1/...`) when creating directories.
- Cloudflare Access policy updated to include operators for `obs.hexwyrm.com`.
- (Optional) Exporters require:
  - Host firewall allowing LAN access to port 9100 (node-exporter).
  - `/opt/dragoncave/configs/telegraf/telegraf.conf` updated with Prometheus inputs targeting `cadvisor`, `node-exporter`, and `smart-exporter`.
  - SMART support on attached drives before enabling `smart-exporter`.
  - `SMARTCTL_DEVICES` defined in `/opt/dragoncave/.env.dragoncave` (e.g. `SMARTCTL_DEVICES=/dev/mmcblk0 /dev/sda`).
  - `PI_HOST_IP` set in `/opt/dragoncave/.env.dragoncave` for Telegraf to scrape node-exporter (e.g. `PI_HOST_IP=192.168.68.145`).

## Configuration
### Loki (`configs/loki/local-config.yaml`)
- Sets single-store BoltDB shippers for chunks and index with 30-day retention.
- Listens on `0.0.0.0:3100` and exposes the HTTP API consumed by Grafana.
- Stores data under `${HOARD1_ROOT}/observability/loki`.

### Promtail (`configs/promtail/config.yml`)
- Uses Docker service discovery via the `dprox` socket proxy.
- Labels logs with container name, compose service, and stack.
- Scrapes host syslogs from `/var/log` for critical services.
- Batches to `http://loki:3100/loki/api/v1/push`.

### Grafana (`configs/grafana/`)
- Directory persists the SQLite database and plugins.
- First-run provisioning: add Loki data source (`http://loki:3100`) and import dashboards `1860` (Node Exporter) and `12019` (Traefik) as needed.
- Optionally add Telegram/Discord alert channels after Phase 3 automation.

## Deployment
```bash
docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/obs-logs.yml config    # Validate syntax
docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/obs-logs.yml up -d     # Deploy stack
docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/obs-exporters.yml config
docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/obs-exporters.yml up -d
```

Post-deploy checks:
- `docker ps` shows `loki`, `promtail`, `grafana` running with restart policy `unless-stopped`.
- `docker ps` shows `cadvisor` and `node-exporter` healthy. `smart-exporter` (profile `storage`) is optional—enable only when drives support SMART.
- Traefik dashboard reports the `obs.hexwyrm.com` router healthy.
- Grafana accessible at https://obs.hexwyrm.com (BasicAuth + Grafana login).
- Explore > Loki returns logs from `edge-traefik`, `cloudflared`, and Portainer containers.
- Metrics endpoints return data:
  - `http://cadvisor:8080/metrics` (reachable from the `core` network).
  - `http://<pi-lan-ip>:9100/metrics` (node-exporter on host network).
  - `http://smart-exporter:9633/metrics` (when the storage profile is enabled).

## Operations
- Rotate Grafana admin password quarterly; update the secret file and redeploy `grafana`.
- Retention tuning: adjust `table_manager.retention_period` in `local-config.yaml`.
- All containers are scraped by default; opt out by adding the label `logging_disabled=true` to the service.
- Enable alerting by creating Grafana alert rules targeting Telegram/Email (Phase 3 integration).
- Backup `${HOARD1_ROOT}/observability/loki` and `${HOARD1_ROOT}/observability/grafana` nightly (restic targets `${VAULT3_ROOT}`).
- Configure metrics ingestion:
  - Prometheus users: add scrape jobs targeting the endpoints listed above.
  - Telegraf users: enable the `inputs.prometheus` stanzas in `configs/telegraf/telegraf.conf` and ensure `INFLUX_TOKEN` carries write permissions.
- Set `SMARTCTL_DEVICES` in `/opt/dragoncave/.env.dragoncave` to list actual disk devices (e.g. `/dev/mmcblk0 /dev/nvme0n1`); restart `smart-exporter` with profile `storage` once values are in place.

## Troubleshooting
- Promtail errors `dial tcp dprox:2375` → confirm `stacks/sec-docker-socket-proxy.yml` is running and network `core` exists.
- Loki HTTP 500 → check disk space on `${HOARD1_ROOT}/observability/loki`; restart container after clearing.
- Grafana login issues → reset admin password by deleting `/opt/dragoncave/configs/grafana/grafana.db` (only as last resort) and re-import dashboards.
- Missing logs → verify Promtail service discovery via `docker logs promtail`, ensure containers include stdout logging and aren’t excluded via labels.
- `cadvisor` 403/permission errors → confirm volume mounts exist and container runs as root; restart after Docker upgrades.
- `node-exporter` unreachable on 9100 → ensure service binds to `0.0.0.0`, no firewall blocks LAN access, and host networking is enabled.
- SMART metrics blank → verify devices listed in `SMARTCTL_DEVICES`, confirm USB enclosures expose SMART, and restart with `--profile storage`.

Phase 2 completes when the observability stack is deployed, the guide remains current, and operational checks confirm log ingestion plus dashboard access.
