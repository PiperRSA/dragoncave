# 🐉 Dragoncave Homelab Installer

Dragoncave is a Raspberry Pi 5 (“dragoncave”) homelab that favours zero‑trust defaults, split-horizon DNS, and immutable automation. This repository contains the Docker Compose stacks, configuration templates, and an idempotent installer that discovers hardware, validates secrets, and brings the environment online end-to-end.

---

## ✅ What the Installer Does

- Detects a Pi 5 running Debian Bookworm, installs Docker + Compose, and prepares `/opt/dragoncave`.
- Clones (or updates) this repository under `/opt/dragoncave/git/dragoncave`.
- Creates `/opt/dragoncave/.env.dragoncave` (from `.env.dragoncave.example`) and auto-loads overrides on every run.
- Discovers Hoard1/Hoard2/Vault3 storage mounts (NVMe/NVMe/USB) and falls back to safe defaults with clear warnings.
- Gathers the secrets required by all stacks, pauses until each file exists in `/opt/dragoncave/secrets`, and never prints secret contents.
- Ensures docker networks (`edge`, `core`, `dns`) exist, then deploys enabled stacks in dependency order.
- Runs comprehensive smoke tests (HTTP, DNS, container status) and prints a status table with pass/fail per service.
- Provides lifecycle flags: `--status`, `--upgrade`, `--reset-soft`, `--reset-hard`, `--uninstall`.

All operations are **idempotent**—re-running the installer reconciles changes without side effects.

---

## 🔧 Quick Start

> **Important:** Create the required secrets listed in [`secrets/README.md`](secrets/README.md) before running the installer. The script checks for them and pauses if any are missing.

### On the Raspberry Pi
```bash
sudo apt-get update
curl -fsSL https://raw.githubusercontent.com/PiperRSA/dragoncave/main/scripts/install.sh | sudo bash
```

### From a Management Machine
```bash
ssh dragonmaster@dragoncave \
  'curl -fsSL https://raw.githubusercontent.com/PiperRSA/dragoncave/main/scripts/install.sh | sudo bash'
```

Re-run the same command any time you want to reconcile changes. The installer will pull the latest Git revision, refresh container images, and rerun smoke tests.

---

## 📁 Repository Layout

```
stacks/                  Compose files (labels-only Traefik pattern)
configs/                 Service configuration templates
scripts/                 Installer, smoke tests, utility helpers
secrets/README.md        Required secret files (no secrets committed)
.env.dragoncave.example  Sample environment overrides
CHANGELOG.md             Operational history
```

Bind mounts are segregated by storage intent (chatty workloads → Hoard1, bulky content → Hoard2, backups → Vault3). Update `.env.dragoncave` if your mounts live elsewhere.

---

## 🧰 Key Commands

| Action | Command |
| --- | --- |
| Install / reconcile | `sudo scripts/install.sh` *(when repo already cloned)* |
| Upgrade only | `sudo scripts/install.sh --upgrade` |
| Status dashboard | `scripts/install.sh --status` *(no sudo required just for status output)* |
| Smoke tests | `scripts/smoke-tests.sh --summary` |
| Soft reset | `sudo scripts/install.sh --reset-soft` (containers/images pruned, data preserved) |
| Hard reset | `sudo scripts/install.sh --reset-hard` (also prunes Docker networks/volumes) |
| Uninstall | `sudo scripts/install.sh --uninstall` (archives `/opt/dragoncave` under `/opt/archive/`) |

---

## 🌐 Core Service Map

| Service | URL | Auth | Storage |
| --- | --- | --- | --- |
| Traefik dashboard | `https://traefik.${PUBLIC_DOMAIN}` | BasicAuth + LAN allow list | `${HOARD1_ROOT}/letsencrypt` |
| Cloudflare Tunnel | (headless) | Tunnel token | `/opt/dragoncave/secrets/CF_TUNNEL_TOKEN` |
| Portainer | `https://portainer.${PUBLIC_DOMAIN}` | BasicAuth + LAN allow list | Docker volume (`portainer_data`) |
| Pi-hole | `https://pihole.${PUBLIC_DOMAIN}` | BasicAuth + LAN allow list | `${HOARD1_ROOT}/apps/pihole` (binds via stack) |
| Observability (Grafana, Loki, Promtail, exporters) | `https://obs.${PUBLIC_DOMAIN}` | BasicAuth + LAN allow list | `${HOARD1_ROOT}/observability/*` |
| Automation (Node-RED, n8n) | `https://flows.${PUBLIC_DOMAIN}` / `https://workflows.${PUBLIC_DOMAIN}` | Access + app credentials | `${HOARD1_ROOT}/apps/*` |
| Data services (Meilisearch, shared DBs) | `https://search.${PUBLIC_DOMAIN}` | API key / BasicAuth | `${HOARD1_ROOT}/databases/*` |
| Content apps (Nextcloud, Paperless, Immich) | `https://cloud.${PUBLIC_DOMAIN}` etc. | Access + app auth | `${HOARD2_ROOT}/...` |

Internal DNS (`*.hexwyrm.home.arpa`) points at `192.168.68.145`, while public DNS (`*.hexwyrm.com`) resolves through Cloudflare + tunnel. Ports 80/443 are the only WAN ingress; DNS (53) stays LAN-only.

---

## ⚙️ Customising the Installation

1. **Environment overrides** – Edit `/opt/dragoncave/.env.dragoncave` (generated from `.env.dragoncave.example`). Update domains, timezone, storage mounts (`HOARD1_ROOT`, `HOARD2_ROOT`, `VAULT3_ROOT`), Cloudflare tokens, restic repository, and `ENABLED_STACKS` (space-separated list of compose files to deploy).
2. **Secrets** – Provide all files documented in [`secrets/README.md`](secrets/README.md). The installer refuses to continue until every file exists.
3. **Additional stacks** – Drop new compose files under `stacks/` following the labels-only pattern. Add the filename to `ENABLED_STACKS` to deploy automatically.
4. **Diagnostics** – Tune `scripts/smoke-tests.sh` or extend the installer’s `CONTAINER_CHECKS` array to cover new services.

---

## 🔍 Diagnostics & Self-Healing

- **Smoke tests**: `scripts/smoke-tests.sh --summary` checks HTTP status, DNS answers, and container health—100% green is the acceptance bar.
- **Installer logs**: `/opt/dragoncave/logs/installer.log` captures every run, including package installs and compose retries.
- **Common triage**:
  - **DNS/ACME** – `docker logs edge-traefik` for ACME errors; ensure `cloudflare.env` tokens are valid and port 53 remains LAN-only.
  - **Tunnel** – `docker logs cloudflared`, verify `CF_TUNNEL_TOKEN`, and confirm `tunnel route dns` entries.
  - **Reverse proxy** – `docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/edge-traefik.yml config` highlights syntax/label issues.
  - **Storage permissions** – ensure Hoard directories belong to UID/GID `1000` or `999` as stacks expect. The installer will recreate missing directories with safe permissions.
  - **App health** – `docker ps --format 'table {{.Names}}\t{{.Status}}'` spots restart loops; check bind mounts under Hoard1/Hoard2 and adjust SELinux/AppArmor if used.

---

## 🔐 Secrets Checklist

See [`secrets/README.md`](secrets/README.md) for the full matrix. Highlights:

- `cloudflare.env` – Cloudflare API token for Traefik ACME (DNS-01).
- `traefik_basicauth.htpasswd` – Shared BasicAuth realm for admin UIs.
- `CF_TUNNEL_TOKEN` – Cloudflare named tunnel credential.
- Application secrets (`*_DB_USER`, `*_DB_PASS`, `GRAFANA_ADMIN_PASS`, `N8N_USER`, `N8N_PASS`, etc.) aligned with stack expectations.
- `RESTIC_PASSWORD` – Unlocks restic backups written to `${VAULT3_ROOT}`.

All secrets live under `/opt/dragoncave/secrets` with `0400` permissions by default.

---

## 🧪 Development Notes

- Run `scripts/install.sh --status` locally to validate container health without redeployment.
- `make preflight` executes `yamllint`, `shellcheck`, and `hadolint` (where Dockerfiles exist).
- Use `scripts/install.sh --upgrade` after updating `.env.dragoncave` or adding stacks; the installer reconciles in place.
- Add new documentation under `docs/` and reference it from the relevant phase README.

---

## 📜 License & Contributing

No formal license yet—treat as “look but don’t publish secrets.” Contributions welcome via pull request; please include:

- Updated smoke tests if new endpoints are introduced.
- Storage intent (Hoard1/Hoard2/Vault3) for any new bind mounts.
- Secrets documentation updates when introducing new credentials.

---

## 📈 Status After Install

The installer finishes by printing a table similar to:

```
CHECK               TARGET                                       RESULT   STATUS
------------------  --------------------------------------------- -------- ------
Traefik             https://traefik.hexwyrm.com                   401      PASS
Portainer           https://portainer.hexwyrm.com                 401      PASS
...

Docker summary:
  - edge-traefik -> Up 6 minutes
  - cloudflared -> Up 6 minutes
  ...
```

If any line reads `FAIL`, consult the diagnostics section above or re-run `scripts/smoke-tests.sh --summary` after fixing the root cause.

Happy homelabbing! 🛠️🔥
