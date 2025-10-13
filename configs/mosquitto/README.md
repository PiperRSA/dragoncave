# Mosquitto Configuration

Mosquitto expects its configuration under `/mosquitto/config`. This directory should at minimum contain `mosquitto.conf` and any password files referenced within it.

Create on the Raspberry Pi:

```bash
sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/mosquitto
```

Sample `mosquitto.conf`:

```conf
persistence true
persistence_location /mosquitto/data/
listener 1883
allow_anonymous false
password_file /mosquitto/config/passwords
```

After updating configuration, redeploy `stacks/iot-home-assistant.yml`.

Persistent broker data is stored on Hoard1 at `${HOARD1_ROOT}/apps/mosquitto`; ensure that directory exists and remains owned by UID/GID 1000:1000.
