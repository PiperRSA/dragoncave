# Phase 5–7 Service Catalog

| Service | Stack file | Default exposure | Auth | Data path |
| --- | --- | --- | --- | --- |
| Pi-hole | stacks/dns-pihole.yml | LAN + admin via Traefik | Basic + LAN allow-list | configs/pihole |
| Uptime-Kuma | stacks/obs-monitoring.yml | LAN | LAN allow-list optional | configs/kuma |
| Dozzle | stacks/obs-monitoring.yml | Admin (LAN + Access) | Basic + LAN allow-list | — |
| Loki/Promtail | stacks/obs-logs.yml | LAN (Grafana only) | Grafana app auth | configs/loki, configs/promtail |
| Grafana | stacks/obs-logs.yml | LAN | Grafana admin secret | configs/grafana |
| Node-RED | stacks/flows-node-red.yml | Optional WAN | App auth + Access | configs/node-red |
| n8n | stacks/jobs-n8n.yml | Optional WAN | Basic + Access | configs/n8n |
| Meilisearch | stacks/search-meili.yml | Optional WAN | API key + Access | data/meili |
| Home Assistant | stacks/iot-home-assistant.yml | LAN | LAN allow-list | configs/homeassistant |
| Mosquitto | stacks/iot-home-assistant.yml | LAN | Client creds | configs/mosquitto |
| InfluxDB | stacks/iot-home-assistant.yml | LAN | Token secret | data/influxdb |
| Telegraf | stacks/iot-home-assistant.yml | Core | — | configs/telegraf |
| Nextcloud | stacks/files-nextcloud.yml | Optional WAN | App auth + Access | data/nextcloud |
| Paperless-ngx | stacks/docs-paperless.yml | Optional WAN | App auth + Access | data/paperless |
| Immich | stacks/photos-immich.yml | LAN-first | App auth + LAN | data/immich |
| Gitea | stacks/dev-gitea.yml | Optional WAN | App auth + Access | data/gitea |
| MinIO | stacks/infra-minio.yml | Admin (LAN + Access) | Basic + Access | data/minio |
| Vaultwarden | stacks/misc-vaultwarden.yml | LAN or Access | Admin token + Access | data/vaultwarden |
| Shared databases | stacks/data-services.yml | Core | Secrets only | data/postgres, data/mariadb, data/redis |
