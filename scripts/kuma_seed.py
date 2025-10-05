#!/usr/bin/env python3
# One-off seeding script for Uptime Kuma

from uptime_kuma_api import UptimeKumaApi, MonitorType
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

KUMA_URL = "https://obs.hexwyrm.com"  # use FQDN so TLS SNI matches
ADMIN_USER = "admin"
ADMIN_PASS = "P!err391535740P1"  # you can rotate later

api = UptimeKumaApi(KUMA_URL, ssl_verify=False)

try:
    if api.need_setup():
        api.setup(ADMIN_USER, ADMIN_PASS)

    api.login(ADMIN_USER, ADMIN_PASS)

    created = []

    created.append(api.add_monitor(
        type=MonitorType.HTTP,
        name="Traefik /ping",
        url="https://traefik.hexwyrm.com/ping",
        interval=60
    ))

    created.append(api.add_monitor(
        type=MonitorType.HTTP,
        name="Portainer API /api/system/status",
        url="https://portainer.hexwyrm.com/api/system/status",
        interval=60
    ))

    created.append(api.add_monitor(
        type=MonitorType.HTTP,
        name="Pi-hole Admin",
        url="https://pihole.hexwyrm.com/admin/",
        interval=60
    ))

    created.append(api.add_monitor(
        type=MonitorType.HTTP,
        name="Dozzle UI (auth)",
        url="https://logs.hexwyrm.com/",
        basic_auth_user=ADMIN_USER,
        basic_auth_pass=ADMIN_PASS,
        interval=60
    ))

    print("CREATED_MONITORS:", [m.get("monitorId") for m in created])

finally:
    try:
        api.disconnect()
    except Exception:
        pass
