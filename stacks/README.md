# Dragoncave Stacks

This folder contains production Docker Compose stacks. Reverse proxy is Traefik v3 on the `edge` network. TLS is terminated at Traefik.

---

## Portainer (behind Traefik)

### Compose file
`stacks/portainer.yml`

### Deploy
```bash
docker compose -f /opt/dragoncave/stacks/portainer.yml --env-file /opt/dragoncave/.env.dragoncave up -d
