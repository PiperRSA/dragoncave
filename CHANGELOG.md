# CHANGELOG

## 2025-10-05 — Observability phase (Uptime Kuma + Dozzle)

- Add stack: /opt/dragoncave/stacks/obs.yml
- Deploy Uptime Kuma at https://obs.hexwyrm.com (Traefik edge, network: edge)
- Deploy Dozzle at https://logs.hexwyrm.com (Traefik edge) protected by BasicAuth middleware `logs-auth@file`
- Traefik dynamic config:
  - /opt/dragoncave/configs/traefik/logs_auth.yml
  - /opt/dragoncave/configs/traefik/logs_basicauth.htpasswd
  - /opt/dragoncave/configs/traefik/ping.yml (exposes `/ping` on traefik.hexwyrm.com)
- Scripts:
  - /opt/dragoncave/scripts/kuma_seed.py
  - /opt/dragoncave/scripts/kuma_list.py
- Local Pi DNS entries:
  - /etc/hosts entries for obs.hexwyrm.com and logs.hexwyrm.com
- Uptime Kuma seeded monitors:
  - Traefik `/ping`
  - Portainer API `/api/system/status`
  - Pi-hole Admin `/admin/`
  - Dozzle UI (auth)
- Health: both services reachable; Dozzle returns 401 unauthenticated, 200 with BasicAuth.

### Green checklist
- [x] SSH ok
- [x] Docker running
- [x] UFW 22/80/443 +53 LAN only
- [x] Containers healthy
- [x] obs.hexwyrm.com and logs.hexwyrm.com reachable via Traefik
