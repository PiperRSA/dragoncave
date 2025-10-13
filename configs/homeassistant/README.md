# Home Assistant Configuration

Home Assistant reads its configuration from `/config`, mapped to this directory.

Set up the directory on the Raspberry Pi:

```bash
sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/homeassistant
```

Store `configuration.yaml` and supporting files here. Use secrets.yaml or Vaultwarden for sensitive values. Back up this directory alongside `${HOARD1_ROOT}/apps/homeassistant` and `${HOARD1_ROOT}/apps/influxdb`.
