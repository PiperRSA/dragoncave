# Telegraf Configuration

Telegraf reads its configuration from `telegraf.conf` in this directory.

Set up on the Raspberry Pi:

```bash
sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/telegraf
```

Update `telegraf.conf` as required for your sensors and input plugins. The template provided in this repository targets InfluxDB v2 using the admin token secret.

Set the following environment variables in `/opt/dragoncave/.env.dragoncave` before starting Telegraf:
- `INFLUX_TOKEN` – admin token created during InfluxDB onboarding.
- `PI_HOST_IP` – LAN IP of the Raspberry Pi (used to scrape node-exporter).
- `SMARTCTL_DEVICES` (optional) – space-separated list of block devices when SMART telemetry is enabled.
