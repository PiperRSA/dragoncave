# Changelog

## 2025-10-13 — Automated Installer & Storage Alignment

- Introduced `scripts/install.sh` for idempotent installs, upgrades, resets, and uninstalls with automatic discovery, secrets gating, and smoke tests.
- Added dedicated exporter stack (`stacks/obs-exporters.yml`) and revamped `scripts/smoke-tests.sh` for HTTP/DNS/container diagnostics.
- Normalised compose bind mounts to Hoard1/Hoard2/Vault3 via `.env.dragoncave` variables; provided `.env.dragoncave.example` defaults.
- Documented secrets, storage layout, and operational guidance (`README.md`, `secrets/README.md`, updated phase runbooks).

## 2025-10-05 — Cloudflare Tunnel (named) + DNS + Traefik

- Added locally-managed Cloudflare Tunnel (`dragoncave`) using named tunnel + `config.yml`.
- Ingress routes via Tunnel → Traefik (`edge` network) with host headers for the public services.
- Created DNS (CNAME) records bound to the tunnel via `tunnel route dns`.
- Hardened Cloudflare zone edge: HTTPS only, TLS ≥1.2, TLS1.3, HTTP/2/3.
- Removed legacy token-based tunnel files from `/opt/dragoncave/secrets/`.

## 2025-10-04 — Portainer & TLS Hardening

- Added Portainer CE stack behind Traefik on `edge` network (`stacks/portainer.yml`).
- Added Traefik TLS file-provider config (`configs/traefik/tls.yml`) and ignored local cert materials.
- Verified routing via SNI and API; added proxy-awareness headers (X-Forwarded-*).
- Wired local wildcard TLS via mkcert; `tls.yml` points Traefik at `/etc/traefik/dynamic/certs/`.
