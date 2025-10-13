# Home & Dev Platform Guide (Phase 7)

Phase 7 delivers home automation and developer tooling, tying together stateful services on the core network.

## Components & Source of Truth
| Component | Stack / Config | Responsibility |
| --- | --- | --- |
| Home Assistant, Mosquitto, InfluxDB, Telegraf | `stacks/iot-home-assistant.yml`, `configs/homeassistant/`, `configs/mosquitto/`, `configs/telegraf/telegraf.conf` | Home automation hub, MQTT broker, telemetry pipeline. |
| Vaultwarden | `stacks/misc-vaultwarden.yml`, `${HOARD1_ROOT}/apps/vaultwarden` | Password manager for homelab secrets. |
| Gitea | `stacks/dev-gitea.yml`, `${HOARD1_ROOT}/apps/gitea` | Self-hosted git service. |
| MinIO | `stacks/infra-minio.yml`, `${HOARD2_ROOT}/minio` | Object storage for backups, Nextcloud, Immich. |
| Shared databases | `stacks/data-services.yml` | Existing Postgres/MariaDB/Redis cluster reused by Phase 5–6 services. |

## Prerequisites
- Phases 1–6 operational.
- Secrets prepared per `docs/SECRETS_TEMPLATE.md`:
  - `INFLUXDB_ADMIN_PASS`, `INFLUXDB_ADMIN_TOKEN`
  - `MINIO_ROOT_USER`, `MINIO_ROOT_PASS`
  - `VAULTWARDEN_ADMIN_TOKEN`
- Directories:
  ```bash
  sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/homeassistant
  sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/mosquitto
  sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/telegraf
  sudo install -d -m 0755 -o 1000 -g 1000 ${HOARD1_ROOT}/apps/{homeassistant,mosquitto,influxdb,vaultwarden,gitea}
  sudo install -d -m 0755 -o 1000 -g 1000 ${HOARD2_ROOT}/minio
  ```
  Replace `${HOARD1_ROOT}`/`${HOARD2_ROOT}` with the actual mount paths (e.g. `/srv/hoard1`, `/srv/hoard2`) or export values from `/opt/dragoncave/.env.dragoncave`.
- Populate `configs/telegraf/telegraf.conf` (template included) and set environment variable `INFLUX_TOKEN` for Telegraf in `.env.dragoncave`.
- Cloudflare Access policies for `home.hexwyrm.com`, `vault.hexwyrm.com`, `git.hexwyrm.com`, `s3.hexwyrm.com`.
- Optional: configure MinIO bucket policies for Nextcloud/Paperless/Immich integrations.

## Deployment Workflow
1. Deploy home automation stack:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/iot-home-assistant.yml config
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/iot-home-assistant.yml up -d
   ```
   - After first start, run Home Assistant onboarding, configure MQTT broker, and create InfluxDB bucket/token.
   - Ensure `INFLUX_TOKEN` environment variable is supplied (e.g. in `/opt/dragoncave/.env.dragoncave`) before starting Telegraf.
2. Deploy supporting services:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/misc-vaultwarden.yml up -d
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/dev-gitea.yml up -d
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/infra-minio.yml up -d
   ```
3. Run `scripts/smoke-tests.sh` to validate hostnames and confirm Traefik routers healthy.
4. Configure Vaultwarden admin interface (https://vault.hexwyrm.com) and import credential collections.
5. Initialise Gitea (https://git.hexwyrm.com) with admin user, configure SMTP/OAuth as needed.
6. Create MinIO buckets for backups (`backups`), Nextcloud external storage (`nextcloud`), and Immich (`immich`).

## Operations
- **Home Assistant**
  - Store configuration YAML in Git (private) or use Vaultwarden for secrets.
  - Integrate Telegraf metrics into Grafana dashboards.
  - Limit WAN exposure; rely on Cloudflare Access and allow lists.
- **Mosquitto**
  - Manage MQTT credentials via password file referenced in `configs/mosquitto`.
  - Enforce TLS once MinIO or ACME certificates available.
- **InfluxDB & Telegraf**
  - Rotate admin token yearly; update `.env.dragoncave` and redeploy Telegraf.
  - Expand retention policies per bucket to manage disk usage.
- **Vaultwarden**
  - Enable 2FA and regular backups of `${HOARD1_ROOT}/apps/vaultwarden`.
  - Rotate `VAULTWARDEN_ADMIN_TOKEN` after admin changes.
- **Gitea**
  - Set up organization/team structure, configure runners if needed.
  - Mirror critical repos to GitHub or off-site storage.
- **MinIO**
  - Enable versioning on critical buckets.
  - Use `mc` CLI for lifecycle policies and replication.
  - Store access/secret keys in Vaultwarden, rotate quarterly.

## Troubleshooting
- Home Assistant integrations failing → check container logs, confirm required USB devices are mapped (update stack accordingly).
- MQTT auth errors → regenerate password file with `mosquitto_passwd`.
- InfluxDB onboarding repeats → ensure `${HOARD1_ROOT}/apps/influxdb` is writable by UID 1000.
- Vaultwarden `Invalid admin token` → regenerate secret and update `/opt/dragoncave/secrets/VAULTWARDEN_ADMIN_TOKEN`.
- MinIO console not loading → confirm Traefik middleware includes BasicAuth credentials, verify `MINIO_ROOT_*` secrets.
- Gitea email not sending → set SMTP settings via `${HOARD1_ROOT}/apps/gitea/custom/conf/app.ini`.

Phase 7 is complete when home automation, credential management, developer tooling, and object storage are deployed with documented maintenance steps.
