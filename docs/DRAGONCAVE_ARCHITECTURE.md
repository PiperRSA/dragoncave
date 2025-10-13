# Dragoncave Architecture

Phase 0 establishes the reference architecture for the Dragoncave Raspberry Pi homelab. The environment prioritises least privilege, audited ingress, and reproducible automation.

## Platform Overview
- **Host:** Raspberry Pi 5 (16 GB RAM) branded `dragoncave`
- **Location:** On-prem LAN at 192.168.68.0/24
- **Operating system:** Debian Bookworm (64-bit)
- **Container runtime:** Docker Engine with Compose v2
- **Reverse proxy:** Traefik v3.1 running as `edge-traefik`
- **Primary domain:** `hexwyrm.com`
- **Internal DNS zone:** `hexwyrm.home.arpa` (served by Pi-hole)
- **Configuration root:** `/opt/dragoncave` on-host, mirrored from this repository
- **Storage tiers:** Hoard1 (`${HOARD1_ROOT}` NVMe) for app data, Hoard2 (`${HOARD2_ROOT}` NVMe) for bulky content, Vault3 (`${VAULT3_ROOT}` USB SSD) for restic backups

## Hardware Naming & DNS
- **Host identity:** `dragoncave` reachable at static IP `192.168.68.145` on the LAN.
- **Split-horizon DNS:** `*.hexwyrm.home.arpa` served internally via Pi-hole; `*.hexwyrm.com` published through Cloudflare DNS and tunnel.
- **Docker networks:** `edge` (ingress), `core` (east–west), `dns` (Pi-hole clients).

## Network Segmentation
| Network | Type | Participants | Purpose | Notes |
| --- | --- | --- | --- | --- |
| `edge` | Docker overlay (external) | Traefik, WAN-published apps, Cloudflared | Terminate TLS, enforce middleware, expose HTTPS | Every service published to the internet joins `edge`. |
| `core` | Docker overlay (external) | Data services, socket proxy, Traefik | East-west traffic between internal services | Traefik uses `core` to reach backend workloads. |
| `dns` | Docker overlay (external) | Pi-hole, DNS-aware services | Provide DNS sinkhole for LAN clients | Created during Phase 4; referenced for completeness. |
| LAN | Physical subnet | Raspberry Pi host, trusted clients | On-premises management and SSH | Admin access restricted to allow-listed IPs. |

Ingress is brokered by Cloudflare:
1. Cloudflare Tunnel terminates client TLS and forwards requests to Traefik on the `edge` network.
2. Traefik applies BasicAuth, IP allow lists, and security headers before proxying containers.
3. LAN clients can reach Traefik directly on ports 80/443 if Cloudflare is unavailable.

## Service Roles (Phase 0 completion)
| Role | Component | Responsibility |
| --- | --- | --- |
| Reverse proxy | `edge-traefik` | ACME DNS-01 certificates via Cloudflare, HTTP to HTTPS redirects, middleware |
| Docker access broker | `dprox` (Docker socket proxy) | Grants read-only socket access for Traefik, Promtail, Watchtower |
| Tunnel egress | `cloudflared` | Named tunnel (`dragoncave`) routing `traefik`, `portainer`, `whoami` |
| Administration | Portainer (Phase 1) | Container lifecycle with least privilege, BasicAuth, LAN allow list |

Future phases (observability, automation, data services) plug into the same networks and reuse middleware patterns defined here.

## Storage Layout
| Location | Backing storage | Purpose |
| --- | --- | --- |
| `/opt/dragoncave/{configs,secrets,scripts,stacks}` | OS drive (SD) | Small, version-controlled assets; easy to edit locally. |
| `${HOARD1_ROOT}` (NVMe “Hoard1”) | High-speed NVMe | Latency-sensitive app data: databases, indexes, observability state. |
| `${HOARD2_ROOT}` (NVMe “Hoard2”) | Large-capacity NVMe | Bulky content: Nextcloud files, Paperless media, Immich libraries, model datasets. |
| `${VAULT3_ROOT}` (USB SSD “Vault3”) | Backup target | Restic repository storing encrypted snapshots of configs + Hoard1/Hoard2 data. |

Environment variables defined in `/opt/dragoncave/.env.dragoncave` (`HOARD1_ROOT`, `HOARD2_ROOT`, `VAULT3_ROOT`) let Compose stacks mount the correct device. Secrets under `/opt/dragoncave/secrets` remain chmod 0400 with service UID/GID ownership.

## Operational Workflows
1. Work is staged in Git branches on `feat/...` or `phase-n/...` naming.
2. `make preflight` enforces linting gates (yamllint, shellcheck, hadolint).
3. `scripts/deploy_changed.sh` deploys only the stacks changed relative to `origin/main`.
4. Health validation uses `scripts/smoke-tests.sh` and Portainer dashboards.

This foundation lets later phases extend the platform without revisiting baseline architecture decisions.
