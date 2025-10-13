# Dragoncave Security Baselines

Phase 0 defines the minimum security posture for every stack deployed in Dragoncave. Later phases inherit and extend these controls.

## Identity & Access
- Gate all WAN-facing entrypoints behind Cloudflare Access and Traefik BasicAuth.
- Restrict administrative surfaces (Traefik, Portainer, Grafana, Dozzle) to the LAN allow list `192.168.68.0/24`.
- Use unique admin credentials per service; never reuse passwords between stacks.
- Store secrets in `/opt/dragoncave/secrets`, chmod 0400, owned by the service UID/GID.
- Rotate secrets when operators change or every six months, whichever comes first.

## Runtime Hardening
- Containers run as non-root users whenever upstream images support it.
- Enable `read_only: true`, `cap_drop: [ALL]`, and `security_opt: [no-new-privileges:true]` unless a service requires extra privileges.
- All Docker socket access goes through the `dprox` proxy with read-only permissions.
- Watchtower auto-updates only for services explicitly labelled `com.centurylinklabs.watchtower.enable=true`.

## Networking
- Use external networks `edge`, `core`, and `dns` to separate ingress, internal traffic, and DNS-aware services.
- Only Traefik binds host ports 80/443; all other services rely on reverse proxy routing.
- Deny inter-container communication by default; explicitly join networks required for function.
- Cloudflare Tunnel is the sole WAN entrypoint. Disable direct port forwarding on the router.

## Observability & Logging
- Centralise HTTP access and error logs through Traefik.
- Promtail collects container logs via the docker socket proxy and ships them to Loki (Phase 2).
- Uptime-Kuma monitors published hostnames; failed checks alert via Telegram (configured in later phases).

## Update & Patch Policy
- Apply OS security updates weekly via unattended-upgrades on the Raspberry Pi host.
- Review upstream container releases monthly; opt into Watchtower for services safe to auto-upgrade.
- Re-run `make preflight` after dependency updates to confirm configuration linting.

## Backup & Recovery
- Persist application data under the NVMe mounts (Hoard1 `${HOARD1_ROOT}`, Hoard2 `${HOARD2_ROOT}`) and back them up nightly to `${VAULT3_ROOT}` with restic.
- Export critical configs (`/opt/dragoncave/configs`, `/opt/dragoncave/secrets`) before major changes.
- Document restore steps per service when the stack is introduced (Phase 2+ deliverable).

These baselines must be met before a stack is promoted past staging or published to the internet.
