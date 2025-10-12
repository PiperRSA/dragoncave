# Dragoncave Blueprints

Pick a blueprint, copy it into `stacks/`, adjust hostnames and paths, then deploy with `docker compose -f stacks/<file>.yml up -d`.

Each blueprint ships with:
- Labels-only Traefik v3 routing on the shared edge network.
- LAN allow-list middleware for admin surfaces.
- Cloudflare Access assumed for WAN entrypoints.
- Non-root, read-only filesystem defaults where upstream images allow.
- Watchtower opt-out by default (opt in per-service via label when safe).
