# Edge Access Guide (Phase 1)

Phase 1 delivers secure ingress for Dragoncave by combining Cloudflare Tunnel, Traefik, and Portainer. This guide documents the deployment, access controls, and recovery patterns for the edge stack.

## Components & Source of Truth
| Component | Stack / Config | Responsibility |
| --- | --- | --- |
| Cloudflared tunnel (`cloudflared`) | `stacks/tunnel-cloudflared.yml`, `configs/cloudflared/config.yml` | Maintains named tunnel `dragoncave`, forwards hostnames to Traefik on the `edge` network. |
| Traefik reverse proxy (`edge-traefik`) | `stacks/edge-traefik.yml`, `configs/traefik/dynamic.yml`, `configs/traefik/tls.yml` | Terminates TLS, enforces middleware, routes requests to backend services. |
| Docker socket proxy (`dprox`) | `stacks/sec-docker-socket-proxy.yml` | Exposes read-only Docker API to Traefik/Promtail/Watchtower. |
| Portainer CE (`portainer`) | `stacks/portainer.yml` | Container lifecycle management with Traefik + BasicAuth protection. |
| Smoke tests | `scripts/smoke-tests.sh` | Verifies published hostnames return HTTP 200/302 and Traefik providers are healthy. |

Supporting documentation: `docs/SECURITY_BASELINES.md`, `docs/NAMING_CONVENTIONS.md`, `docs/DRAGONCAVE_ARCHITECTURE.md`.

## Prerequisites
- Cloudflare account with a zone for `hexwyrm.com`.
- Tunnel credentials JSON and token stored on the Pi:
  - `/opt/dragoncave/secrets/CF_TUNNEL_TOKEN` (uid/gid 1000, mode 0400).
  - `/opt/dragoncave/configs/cloudflared/*.json` copied from Cloudflare dashboard.
- Traefik/Portainer BasicAuth file at `/opt/dragoncave/secrets/traefik_basicauth.htpasswd` (owned by root, mode 0400).
- External Docker networks created once on the Pi:
  ```bash
  docker network create edge
  docker network create core
  docker network create dns
  ```
- Cloudflare DNS CNAME records pointing `*.hexwyrm.com` hostnames to the tunnel UUID (`<uuid>.cfargotunnel.com`). `cloudflared tunnel route dns` can create these automatically.

## Deployment Workflow
1. Sync repository updates to the Pi (`scripts/pi_sync_main.sh`) and ensure `/opt/dragoncave` mirrors the latest branch.
2. Deploy or refresh stacks in this order:
   ```bash
   docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/sec-docker-socket-proxy.yml up -d
   docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/edge-traefik.yml up -d
   docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/tunnel-cloudflared.yml up -d
   docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/portainer.yml up -d
   ```
3. Run `scripts/smoke-tests.sh` to confirm HTTP responses. Expect 200/302 for `traefik.hexwyrm.com`, `portainer.hexwyrm.com`, and Cloudflare tunnel hosts.
4. Verify Traefik dashboard:
   - LAN: https://traefik.hexwyrm.com/dashboard/ (BasicAuth credentials in `traefik_basicauth.htpasswd`).
   - Cloudflare Access: ensure Access policy allows operator identities before exposing DNS.
5. Confirm Portainer shows the `edge-traefik`, `cloudflared`, and `dprox` containers healthy with restart policy `unless-stopped`.

## Access Controls
- Cloudflare Access policies restrict WAN entrypoints to trusted users. Update policies through the Cloudflare dashboard; changes take effect immediately on the tunnel.
- Traefik middleware (`configs/traefik/dynamic.yml`) layers IP allow lists for LAN-admin surfaces and BasicAuth for all dashboards.
- Portainer receives the same BasicAuth file via Docker secret (`/run/secrets/traefik_basicauth`) and is chained with Traefik’s `lan-ipwhitelist` middleware.
- Disable router port forwarding to keep all ingress flowing through Cloudflare.

## Certificates & Encryption
- Traefik uses the `cloudflare` ACME resolver in `stacks/edge-traefik.yml` to request SAN certificates via DNS-01.
- Certificates are persisted in `${HOARD1_ROOT}/letsencrypt/acme.json`. Back up this file with the nightly restic job targeting `${VAULT3_ROOT}`.
- Wildcard fallback certificates live in `configs/traefik/tls.yml` under `/opt/dragoncave/configs/traefik/certs/`.
- Cloudflare tunnel connections are encrypted; set the zone to “Full (strict)” SSL/TLS mode.

## Operations & Maintenance
- Update BasicAuth credentials with `htpasswd -B /opt/dragoncave/secrets/traefik_basicauth.htpasswd dragon` and redeploy Traefik/Portainer.
- Review Traefik logs via `docker logs edge-traefik` or through Portainer > Containers.
- To rotate the Cloudflare tunnel token, download the new `cert.json` and token, replace files under `/opt/dragoncave`, then `docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/tunnel-cloudflared.yml up -d`.
- Watchtower is disabled for edge services by design; perform manual updates after testing new container tags.

## Troubleshooting & Recovery
- If Traefik fails to start, check for syntax errors with `docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/edge-traefik.yml config` and validate `configs/traefik/dynamic.yml` using `yamllint`.
- For tunnel issues, run `docker logs cloudflared` and confirm DNS CNAMEs still reference the tunnel UUID.
- To restore from backup, redeploy networks, copy secrets/configs back into `/opt/dragoncave`, then re-run the deployment workflow.
- Keep a fallback SSH ingress (e.g. Tailscale) for out-of-band access when Cloudflare is offline.

Phase 1 is complete when these instructions are current, the edge stack is running, and ingress is verified via smoke tests and Portainer dashboards.
