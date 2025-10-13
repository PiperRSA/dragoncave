# Media & Workflows Guide (Phase 6)

Phase 6 combines media services with automation backends. Immich provides photo management while Node-RED, n8n, and Meilisearch integrate search and workflow triggers.

## Components & Source of Truth
| Component | Stack / Config | Responsibility |
| --- | --- | --- |
| Immich (`immich-server`, `immich-postgres`, `immich-redis`) | `stacks/photos-immich.yml` | Photo/video ingestion, dedupe, AI tagging. |
| Node-RED / n8n | `stacks/flows-node-red.yml`, `stacks/jobs-n8n.yml` | Automation triggers and post-processing (Phase 3 reference). |
| Meilisearch | `stacks/search-meili.yml` | Search index for Immich metadata (Phase 4 reference). |

## Prerequisites
- Phases 1–5 operational, including Meilisearch and automation services.
- Secrets:
  ```bash
  sudo sh -c 'echo "<dbuser>" > /opt/dragoncave/secrets/IMMICH_DB_USER'
  sudo sh -c 'echo "<dbpass>" > /opt/dragoncave/secrets/IMMICH_DB_PASS'
  sudo chown 999:999 /opt/dragoncave/secrets/IMMICH_DB_USER /opt/dragoncave/secrets/IMMICH_DB_PASS
  sudo chmod 0440 /opt/dragoncave/secrets/IMMICH_DB_USER /opt/dragoncave/secrets/IMMICH_DB_PASS
  ```
- Data directories:
  ```bash
  sudo install -d -m 0750 -o 1000 -g 1000 ${HOARD2_ROOT}/immich/photos
  sudo install -d -m 0750 -o 999 -g 999 ${HOARD1_ROOT}/databases/postgres/immich
  ```
  Replace the variables with actual mount points (e.g. `/srv/hoard2`, `/srv/hoard1`) or export them from `/opt/dragoncave/.env.dragoncave` before running the commands.
- DNS + Access policies for `photos.hexwyrm.com`.
- Optional: configure S3 (MinIO) bucket for Immich storage once Phase 7 MinIO is online.

## Deployment Workflow
1. Validate compose file:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/photos-immich.yml config
   ```
2. Deploy:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/photos-immich.yml up -d
   ```
3. Run `scripts/smoke-tests.sh` and verify `photos.hexwyrm.com` returns 302/200.
4. Log into Immich using the initial admin account created on first launch.
5. Connect Immich to Meilisearch (Settings → Search) using the `MEILI_MASTER_KEY`.
6. Build automation flows in Node-RED/n8n to notify on new uploads or route processed content.

## Operations
- Storage scaling: monitor `${HOARD2_ROOT}/immich/photos`; move to MinIO or external mounts when capacity approaches limits.
- Backups: use Immich CLI backup jobs plus Postgres dumps. Mirror `${HOARD2_ROOT}/immich/photos` to `${VAULT3_ROOT}` (restic) or secondary storage.
- Performance tuning: adjust Immich concurrency via environment variables (`IMMICH_WORKERS`) if resource constrained.
- Integrations: configure webhooks to Node-RED for new media, update Meilisearch indexes automatically.
- Observability: add Grafana panels covering Immich container metrics and HTTP latency.

## Troubleshooting
- Upload failures → check `docker logs immich-server` for ffmpeg errors; ensure hardware acceleration configuration matches Pi capabilities.
- Database migrations stuck → inspect `docker logs immich-postgres`; restore from backup if necessary.
- Redis connection errors → confirm `immich-redis` container is running and reachable on the `core` network.
- Search not returning results → ensure Meilisearch index exists and API key matches; re-sync from Immich admin UI.

Phase 6 completes when Immich is online, integrated with Meilisearch and automation pipelines, and a storage growth plan is in place.
