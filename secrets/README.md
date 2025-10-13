# Dragoncave Secrets Directory

Place all sensitive files in this folder **before** running the installer. Files must be owned by root (or the service UID noted) and set to `0400` unless specified otherwise.

| Secret file | Purpose | Consumed by | Notes |
| --- | --- | --- | --- |
| cloudflare.env | ACME DNS-01 credentials (e.g. `CF_API_EMAIL`, `CF_API_TOKEN`) | Traefik (`stacks/edge-traefik*.yml`) | Mode `0400`, no quotes around values. |
| traefik_basicauth.htpasswd | HTTP BasicAuth credentials for admin surfaces | Traefik/Portainer | Generate via `htpasswd -B`. |
| CF_TUNNEL_TOKEN | Cloudflare tunnel token | `stacks/tunnel-cloudflared.yml` | Paste token string; no trailing newline. |
| PIHOLE_ADMIN_PASS | Pi-hole admin password | `stacks/dns-pihole.yml` | UID:GID `0:0`. |
| GRAFANA_ADMIN_PASS | Grafana admin password | `stacks/obs-logs.yml` | UID:GID `1000:1000`. |
| N8N_USER / N8N_PASS | n8n BasicAuth credentials | `stacks/jobs-n8n.yml` | UID:GID `1000:1000`. |
| MEILI_MASTER_KEY | Meilisearch master key | `stacks/search-meili.yml` | UID:GID `1000:1000`. |
| INFLUXDB_ADMIN_PASS | InfluxDB bootstrap password | `stacks/iot-home-assistant.yml` | UID:GID `1000:1000`. |
| INFLUXDB_ADMIN_TOKEN | InfluxDB bootstrap token | `stacks/iot-home-assistant.yml` | UID:GID `1000:1000`. |
| VAULTWARDEN_ADMIN_TOKEN | Vaultwarden admin token | `stacks/misc-vaultwarden.yml` | UID:GID `1000:1000`. |
| MINIO_ROOT_USER / MINIO_ROOT_PASS | MinIO root credentials | `stacks/infra-minio.yml` | UID:GID `1000:1000`. |
| NEXTCLOUD_DB_USER / NEXTCLOUD_DB_PASS | Nextcloud database credentials | `stacks/files-nextcloud.yml` | UID:GID `999:999`. |
| PAPERLESS_DB_USER / PAPERLESS_DB_PASS | Paperless database credentials | `stacks/docs-paperless.yml` | UID:GID `999:999`. |
| IMMICH_DB_USER / IMMICH_DB_PASS | Immich database credentials | `stacks/photos-immich.yml` | UID:GID `999:999`. |
| POSTGRES_USER / POSTGRES_PASSWORD | Shared Postgres credentials | `stacks/data-services.yml` | UID:GID `999:999`. |
| MARIADB_USER / MARIADB_PASS / MARIADB_ROOT_PASS | MariaDB credentials | `stacks/data-services.yml` | UID:GID `999:999`. |
| RESTIC_PASSWORD | Password for restic repository | Installer + backup scripts | Optional but recommended; mode `0400`. |

The installer automatically checks for these files and pauses until all required secrets exist. Do **not** store plaintext inside `.env.dragoncave`; always reference secret files instead.
