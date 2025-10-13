# Data Services Guide (Phase 4)

Phase 4 focuses on core data services that support DNS, search, and shared databases. This guide outlines deployment, configuration, and maintenance.

## Components & Source of Truth
| Component | Stack / Config | Responsibility |
| --- | --- | --- |
| Pi-hole (`pihole`) | `stacks/dns-pihole.yml`, `configs/pihole/` | LAN DNS sinkhole and DHCP (optional). |
| Meilisearch (`meili`) | `stacks/search-meili.yml` | Full-text search for knowledge and media apps. |
| Shared databases (`postgres`, `mariadb`, `redis`) | `stacks/data-services.yml` | Central database cluster for downstream services. |

## Prerequisites
- Phases 1–3 deployed (edge, observability, automation).
- Secrets:
  - `/opt/dragoncave/secrets/PIHOLE_ADMIN_PASS` (root-owned, mode 0400).
  - `/opt/dragoncave/secrets/MEILI_MASTER_KEY` (uid/gid 1000).
  - Shared DB credentials listed in `docs/SECRETS_TEMPLATE.md`.
- Directories:
  ```bash
  sudo install -d -m 0755 -o 0 -g 0 /opt/dragoncave/configs/pihole/etc-pihole
  sudo install -d -m 0755 -o 0 -g 0 /opt/dragoncave/configs/pihole/etc-dnsmasq.d
  sudo install -d -m 0755 -o 1000 -g 1000 ${HOARD1_ROOT}/search/meili
  sudo install -d -m 0755 -o 999 -g 999 ${HOARD1_ROOT}/databases/postgres/shared
  sudo install -d -m 0755 -o 999 -g 999 ${HOARD1_ROOT}/databases/mariadb
  sudo install -d -m 0755 -o 1000 -g 1000 ${HOARD1_ROOT}/databases/redis
  ```
  Replace `${HOARD1_ROOT}` with the actual mount point (e.g. `/srv/hoard1`) or export values from `/opt/dragoncave/.env.dragoncave` before running the commands.
- Docker networks `edge`, `core`, and `dns` created.
- Router/DHCP plan for introducing Pi-hole (decide on replacing existing DNS server).

## Deployment Workflow
1. Validate compose definitions:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/dns-pihole.yml config
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/search-meili.yml config
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/data-services.yml config
   ```
2. Deploy stacks in order (databases first to satisfy dependencies):
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/data-services.yml up -d
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/search-meili.yml up -d
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/dns-pihole.yml up -d
   ```
3. Check health:
   - `docker ps` to confirm containers running.
   - https://pihole.hexwyrm.com (Traefik BasicAuth + Pi-hole login).
   - https://search.hexwyrm.com with API key `MEILI_MASTER_KEY`.
4. Update LAN DHCP/DNS so clients resolve via Pi-hole; verify using `dig example.com` from clients.
5. Register DB connection strings in Vaultwarden for downstream services.

## Operations
- **Pi-hole:** edit blocklists under `/opt/dragoncave/configs/pihole/etc-pihole`; use `gravity.sh` from inside container to refresh. Monitor query logs; keep BasicAuth + LAN allow list enforced.
- **Meilisearch:** add indexes using API; rotate `MEILI_MASTER_KEY` and update downstream clients. Watch storage growth under `${HOARD1_ROOT}/search/meili`.
- **Postgres/MariaDB/Redis:** allocate per-service databases; enforce credentials via Docker secrets. Use `pg_dump`/`mariabackup` for backups stored externally.
- Backups: include `${HOARD1_ROOT}/databases`, `${HOARD1_ROOT}/search`, and `/opt/dragoncave/configs/pihole` in nightly restic jobs targeting `${VAULT3_ROOT}`.
- Observability: add Loki log queries for `pihole` and `meili` containers; set Grafana alerts for error rate spikes.

## Troubleshooting
- Pi-hole port conflicts → ensure no other DNS server binds port 53 on the Pi; stop systemd-resolved if necessary.
- Meilisearch 401 → confirm API key matches `MEILI_MASTER_KEY`; rotate if leaked.
- Database permission errors → verify secrets files contain correct credentials and services mount them with UID/GID 999 or 1000 as required.
- Performance issues → scale Postgres and Redis memory via Docker resource limits, monitor with Grafana dashboards.

Phase 4 closes when the data services are live, traffic flows through Pi-hole, and search/databases are documented under this runbook.
