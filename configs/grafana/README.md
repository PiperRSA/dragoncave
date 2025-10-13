# Grafana Data Directory

This folder is mounted into the Grafana container at `/var/lib/grafana`. It persists the SQLite database, plugins, and provisioning artifacts.

Recommended setup on the Raspberry Pi (assumes`HOARD1_ROOT=/srv/hoard1` in `/opt/dragoncave/.env.dragoncave`):

```bash
sudo install -d -m 0755 -o 1000 -g 1000 ${HOARD1_ROOT}/observability/grafana
sudo chown 1000:1000 ${HOARD1_ROOT}/observability/grafana
```

Back up `${HOARD1_ROOT}/observability/grafana` along with `${HOARD1_ROOT}/observability/loki`.
