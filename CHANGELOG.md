# Changelog

## 2025-10-04
- Add Portainer CE stack behind Traefik on `edge` network (`stacks/portainer.yml`)
- Add Traefik TLS file-provider config (`configs/traefik/tls.yml`)
- Ignore local TLS cert materials in Git (`.gitignore`)
- Verified routing via SNI and API; added proxy-awareness headers (X-Forwarded-*)
- Local wildcard TLS via mkcert; `tls.yml` points Traefik at `/etc/traefik/dynamic/certs/`
