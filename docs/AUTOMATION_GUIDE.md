# Automation Guide (Phase 3)

Phase 3 delivers workflow automation via Node-RED and n8n. This guide outlines prerequisites, deployment, and operational practices.

## Components & Source of Truth
| Component | Stack / Config | Responsibility |
| --- | --- | --- |
| Node-RED (`node-red`) | `stacks/flows-node-red.yml`, `configs/node-red/` | Low-code automations, webhook intake, quick integrations. |
| n8n (`n8n`) | `stacks/jobs-n8n.yml`, `configs/n8n/` | Job scheduler and API-first automation engine. |
| Secrets | `/opt/dragoncave/secrets/N8N_USER`, `/opt/dragoncave/secrets/N8N_PASS` | BasicAuth for n8n web UI and API. |

## Prerequisites
- Phase 1 edge stack and Phase 2 observability operational.
- Secrets created with:
  ```bash
  sudo sh -c 'echo "<user>" > /opt/dragoncave/secrets/N8N_USER'
  sudo sh -c 'echo "<password>" > /opt/dragoncave/secrets/N8N_PASS'
  sudo chown 1000:1000 /opt/dragoncave/secrets/N8N_USER /opt/dragoncave/secrets/N8N_PASS
  sudo chmod 0400 /opt/dragoncave/secrets/N8N_USER /opt/dragoncave/secrets/N8N_PASS
  ```
- Data directories prepared:
  ```bash
  sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/node-red
  sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/n8n
  ```
- Cloudflare Access rules updated to include operators for `flows.hexwyrm.com` and `workflows.hexwyrm.com`.

## Deployment Workflow
1. Validate compose files:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/flows-node-red.yml config
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/jobs-n8n.yml config
   ```
2. Deploy stacks:
   ```bash
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/flows-node-red.yml up -d
  docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/jobs-n8n.yml up -d
   ```
3. Run `scripts/smoke-tests.sh` to verify HTTPS routers return 200/302.
4. Open Portainer to confirm both containers are healthy and joined to `edge` + `core` networks.
5. Log in:
   - Node-RED: https://flows.hexwyrm.com (Traefik BasicAuth, then Node-RED editor).
   - n8n: https://workflows.hexwyrm.com (Traefik BasicAuth + n8n BasicAuth credentials).

## Operations
- Source control: export Node-RED flows and n8n workflows to Git when stable; store sensitive credentials in Vaultwarden or secrets.
- Backups: include `/opt/dragoncave/configs/node-red` and `/opt/dragoncave/configs/n8n` in nightly backups.
- Updates: redeploy stacks after verifying upstream releases; Watchtower is enabled only for containers labelled `true`.
- Integrations: use `scripts/obs-logs` dashboards to monitor automation endpoints and set Grafana alerts on failure metrics.
- Environment variables: configure per-automation secrets via `.env.dragoncave` and reference using Node-RED environment support or n8n credential storage.

## Troubleshooting
- Node-RED editor inaccessible → confirm Traefik router `nodered@docker` exists and BasicAuth credentials are valid.
- n8n 502 errors → inspect `docker logs n8n` for database migration issues; ensure `/opt/dragoncave/configs/n8n` is writable by UID 1000.
- Lost workflows → restore from last backup of the configs directories.
- High latency → inspect network path via Grafana dashboards; consider enabling queue worker scaling in n8n by extending the stack.

Phase 3 completes when both automation services are documented, deployed, and integrated with monitoring under this runbook.
