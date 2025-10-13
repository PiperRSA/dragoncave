# Knowledge & Productivity Guide (Phase 5)

Phase 5 introduces collaborative document services: Nextcloud for file sync and Paperless-ngx for document management. This guide captures deployment and operations.

## Components & Source of Truth
| Component | Stack / Config | Responsibility |
| --- | --- | --- |
| Nextcloud (`nextcloud`, `postgres`) | `stacks/files-nextcloud.yml` | File sync, calendar, contacts. |
| Paperless-ngx (`paperless`, `redis`, `postgres`) | `stacks/docs-paperless.yml` | Document ingestion, OCR, tagging. |
| Shared databases | `stacks/data-services.yml` (optional reuse) | Provide managed Postgres if consolidating. |

## Prerequisites
- Phases 1–4 live (edge, observability, automation, data services).
- Secrets created:
  ```bash
  # Nextcloud
  sudo sh -c 'echo "<dbuser>" > /opt/dragoncave/secrets/NEXTCLOUD_DB_USER'
  sudo sh -c 'echo "<dbpass>" > /opt/dragoncave/secrets/NEXTCLOUD_DB_PASS'

  # Paperless
  sudo sh -c 'echo "<dbuser>" > /opt/dragoncave/secrets/PAPERLESS_DB_USER'
  sudo sh -c 'echo "<dbpass>" > /opt/dragoncave/secrets/PAPERLESS_DB_PASS'
  ```
  Ensure UID/GID ownership 999.
- Directories:
  ```bash
  sudo install -d -m 0750 -o 1000 -g 1000 ${HOARD2_ROOT}/nextcloud
  sudo install -d -m 0750 -o 1000 -g 1000 ${HOARD2_ROOT}/paperless/{data,media,consume}
  sudo install -d -m 0750 -o 999 -g 999 ${HOARD1_ROOT}/databases/postgres/{nextcloud,paperless}
  ```
  Substitute `${HOARD1_ROOT}`/`${HOARD2_ROOT}` with the mounted paths (e.g. `/srv/hoard1`, `/srv/hoard2`) or export variables from `/opt/dragoncave/.env.dragoncave` first.
- DNS + Access: allow operators via Cloudflare Access for `cloud.hexwyrm.com` and `docs.hexwyrm.com`.
- Optional: integrate with Phase 4 shared Postgres instead of stack-local instances by updating environment variables.

## Deployment Workflow
1. Validate stacks:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/files-nextcloud.yml config
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/docs-paperless.yml config
   ```
2. Deploy Nextcloud first:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/files-nextcloud.yml up -d
   ```
   Initialise via web UI; set admin account and configure SMTP, defaults.
3. Deploy Paperless:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/docs-paperless.yml up -d
   ```
   Access admin UI at https://docs.hexwyrm.com and create user accounts.
4. Run `scripts/smoke-tests.sh`; confirm both hostnames return 200/302.
5. Configure backups (see below) before onboarding users.

## Operations
- **Nextcloud**
  - Enable 2FA and external storage modules as needed.
  - Configure object storage (MinIO) once Phase 7 is available using `S3` backend.
  - Use built-in cron via system cron job hitting `cron.php` or Node-RED flow.
- **Paperless**
  - Add automation to drop scans into `${HOARD2_ROOT}/paperless/consume`.
  - Configure mail ingestion for receipts; ensure secrets stored in Vaultwarden.
  - Set retention policies and tags aligned with organisational taxonomy.
- Monitoring: add Grafana panels for HTTP latency and Postgres resource usage.
- Backups:
  - Database dumps: `pg_dump` per service nightly.
  - Data directories: include `${HOARD2_ROOT}/nextcloud` and `${HOARD2_ROOT}/paperless/{data,media,consume}` in the restic snapshot to `${VAULT3_ROOT}`.
  - Test restores quarterly in staging.

## Troubleshooting
- Nextcloud maintenance mode after container restart → run `docker exec nextcloud php occ maintenance:mode --off`.
- Paperless ingestion stuck → inspect redis queue via `docker exec -it redis redis-cli LLEN paperless` and review logs.
- Database migrations failing → check `docker logs postgres` (per stack) for permission errors; confirm secrets values.
- Storage growth → use Nextcloud "Files" analytics and Paperless "Storage" report; expand volumes or move to shared storage.

Phase 5 is complete when both services run behind Traefik, backups are configured, and user onboarding/runbooks are established.
