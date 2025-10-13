# Dragoncave Naming Conventions

Consistent naming keeps stacks predictable and simplifies automation. Phase 0 sets the ground rules applied across all phases.

## Hosts & Domains
- Primary host is `dragoncave` (Raspberry Pi 5) on 192.168.68.145.
- Public hostnames follow `<app>.hexwyrm.com` (e.g. `traefik.hexwyrm.com`, `portainer.hexwyrm.com`).
- Internal-only services may expose `.lan` hostnames in Pi-hole once deployed (Phase 4).

## Docker Compose
- Stack files live under `stacks/` and use `kebab-case` describing the domain (`edge-traefik.yml`, `obs-logs.yml`).
- Service names are scoped to the stack and use matching `kebab-case` (`edge-traefik`, `dprox`, `uptime-kuma`).
- Containers that must be referenced externally set `container_name` equal to the service name.
- Networks referenced across stacks use shared external names: `edge`, `core`, `dns`.

## Git & Branching
- Features follow `feat/<focus>` (e.g. `feat/phase-structure-v1`).
- Phase deliverables use `phase-<number>/<topic>` for easier tracking (`phase-1/edge-hardening`).
- Synchronisation with the Raspberry Pi uses `sync/pi-<date>` naming in automation scripts.

## Secrets & Environment
- Secrets use uppercase snake case matching their consuming service (`GRAFANA_ADMIN_PASS`, `MEILI_MASTER_KEY`).
- File names under `/opt/dragoncave/secrets` mirror the variable name (e.g. `GRAFANA_ADMIN_PASS`).
- `.env` files attach to stacks as needed; the shared example is `.env.dragoncave`.

## Documentation
- Phase guides live in `phase-<n>/README.md`.
- Supporting docs reside in `docs/` with uppercase snake case names (`SECURITY_BASELINES.md`).
- Changelog entries start with ISO date (`YYYY-MM-DD`) and a concise headline.

Following these conventions ensures linting, preflight checks, and automation scripts behave consistently.
