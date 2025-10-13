# Add a Service

1. Copy the relevant stack from `stacks/` to your deployment host or enable it in-place.
2. Create required secrets in `/opt/dragoncave/secrets` with `chmod 0400` and matching UID/GID. Never commit secrets.
3. Ensure external networks exist: `edge`, `core`, and `dns` (Pi-hole only).
4. Run `docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/<file>.yml config` then `docker compose --env-file /opt/dragoncave/.env.dragoncave -f stacks/<file>.yml up -d`.
5. Verify health with `scripts/smoke-tests.sh` and register the endpoint in Uptime-Kuma.

> WAN exposure rule: gate the hostname behind Cloudflare Access and BasicAuth (if applicable) before publishing DNS.
