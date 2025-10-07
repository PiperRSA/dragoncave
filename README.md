# 🐉 Dragoncave Homelab

This repository stores the Docker Compose stacks and configuration files for **Dragoncave**, a Raspberry Pi 5 homelab environment.

## System Overview
- **Host:** `dragoncave` (Raspberry Pi 5, 16GB RAM)
- **Domain:** `hexwyrm.com`
- **Operating system:** Debian Bookworm (64-bit)
- **Reverse proxy:** Traefik v3.1.4

## Repository Layout
```
stacks/
└── edge-traefik.yml   → Traefik reverse proxy (main entrypoint for the lab)

configs/traefik/
├── dynamic.yml        → Dynamic Traefik configuration (dashboard, API, redirects, test routes)
└── tls.yml            → TLS certificates/options loaded by Traefik

configs/cloudflared/
└── config.yml         → Cloudflare Tunnel configuration

.env.example           → Sample environment variables
.gitignore             → Prevents secrets and sensitive files from being committed
README.md              → Project documentation
```

## Prerequisites
- Docker Engine and Docker Compose plugin installed on the Raspberry Pi host.
- An `.env` file populated at `/opt/dragoncave/.env.dragoncave`.
- Secrets stored under `/opt/dragoncave/secrets/`, including `TRAEFIK_BASIC_AUTH`.
- External Docker network named `edge` (used by the Traefik stack).

## Deployment
1. **Clone the repository** (already present on the host):
   ```bash
   git clone https://github.com/PiperRSA/dragoncave.git /opt/dragoncave/git/dragoncave
   cd /opt/dragoncave/git/dragoncave
   ```
2. **Configure environment variables:**
   ```bash
   cp .env.example /opt/dragoncave/.env.dragoncave
   nano /opt/dragoncave/.env.dragoncave
   ```
   Replace placeholder values (domain, email, etc.) with the production values for Dragoncave.
3. **Launch the stack:**
   ```bash
   docker compose -f stacks/edge-traefik.yml --env-file /opt/dragoncave/.env.dragoncave up -d
   ```
4. **Verify container status and logs:**
   ```bash
   docker ps
   docker logs -f edge-traefik
   ```

## Secrets Management
Secrets are stored on the host at `/opt/dragoncave/secrets/`. Example:
- `TRAEFIK_BASIC_AUTH` – stores the Basic Auth credentials for the Traefik dashboard and API.

These paths are excluded from source control via `.gitignore`.

## Current Features
- Traefik v3.1.4 reverse proxy
- HTTPS dashboard and API endpoints:
  - <https://traefik.hexwyrm.com/dashboard/>
  - <https://traefik.hexwyrm.com/api/rawdata>
- Basic Auth enabled (`dragon:<password>` from the secrets file)
- Root redirect from <https://traefik.hexwyrm.com/> to `/dashboard/`
- Sample service routed to <https://whoami.hexwyrm.com>

## Roadmap
- Add Portainer (`portainer.hexwyrm.com`)
- Add Pi-hole for DNS/ad blocking (`pihole.hexwyrm.com`)
- Add Watchtower for automatic container updates
- Expand dynamic Traefik configuration with additional stacks
- Configure a Cloudflare Tunnel for external HTTPS access

---

Managed from `dragoncave` @ `192.168.68.145`.
