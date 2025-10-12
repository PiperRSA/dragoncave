# Secrets Template

Create the following files under `/opt/dragoncave/secrets` with `chmod 0400` and ownership matching the container UID/GID noted.

| Secret file | Purpose | Consumed by | UID:GID |
| --- | --- | --- | --- |
| CF_TUNNEL_TOKEN | Cloudflared tunnel token | stacks/tunnel-cloudflared.yml | 1000:1000 |
| TRAEFIK_BASICAUTH | BasicAuth users (htpasswd) | Traefik, Portainer, admin apps | 0:0 |
| PIHOLE_ADMIN_PASS | Pi-hole admin password | stacks/dns-pihole.yml | 0:0 |
| GRAFANA_ADMIN_PASS | Grafana admin password | stacks/obs-logs.yml | 1000:1000 |
| N8N_USER / N8N_PASS | n8n HTTP auth | stacks/jobs-n8n.yml | 1000:1000 |
| MEILI_MASTER_KEY | Meilisearch master key | stacks/search-meili.yml | 1000:1000 |
| INFLUXDB_ADMIN_PASS | InfluxDB admin password | stacks/iot-home-assistant.yml | 1000:1000 |
| INFLUXDB_ADMIN_TOKEN | InfluxDB token | stacks/iot-home-assistant.yml | 1000:1000 |
| NEXTCLOUD_DB_USER / NEXTCLOUD_DB_PASS | Nextcloud database credentials | stacks/files-nextcloud.yml | 999:999 |
| PAPERLESS_DB_USER / PAPERLESS_DB_PASS | Paperless database credentials | stacks/docs-paperless.yml | 999:999 |
| IMMICH_DB_USER / IMMICH_DB_PASS | Immich database credentials | stacks/photos-immich.yml | 999:999 |
| MINIO_ROOT_USER / MINIO_ROOT_PASS | MinIO root access | stacks/infra-minio.yml | 1000:1000 |
| VAULTWARDEN_ADMIN_TOKEN | Vaultwarden admin token | stacks/misc-vaultwarden.yml | 1000:1000 |
| POSTGRES_USER / POSTGRES_PASSWORD | Shared Postgres credentials | stacks/data-services.yml | 999:999 |
| MARIADB_USER / MARIADB_PASS / MARIADB_ROOT_PASS | MariaDB credentials | stacks/data-services.yml | 999:999 |
