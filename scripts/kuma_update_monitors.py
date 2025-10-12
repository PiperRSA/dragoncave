#!/usr/bin/env python3
from uptime_kuma_api import UptimeKumaApi, MonitorType

KUMA_URL = "https://obs.hexwyrm.com"
KUMA_USER = "admin"
KUMA_PASS = "P!err391535740P1"

api = UptimeKumaApi(KUMA_URL, ssl_verify=False)
api.login(KUMA_USER, KUMA_PASS)

# Ensure a monitor exists for the Kuma UI homepage (expect 200)
target_name_obs = "Kuma UI (obs.hexwyrm.com)"
existing = {m["name"]: m for m in api.get_monitors()}
if target_name_obs in existing:
    m = existing[target_name_obs]
    api.edit_monitor(
        m["id"],
        type=MonitorType.HTTP,
        name=target_name_obs,
        url="https://obs.hexwyrm.com/",
        interval=60,
        method="GET",
        expected_status_codes="200-299",
        ignore_tls=True,
    )
    print(f"UPDATED: {target_name_obs}")
else:
    api.add_monitor(
        type=MonitorType.HTTP,
        name=target_name_obs,
        url="https://obs.hexwyrm.com/",
        interval=60,
        method="GET",
        expected_status_codes="200-299",
        ignore_tls=True,
    )
    print(f"CREATED: {target_name_obs}")

# Switch Dozzle to Basic Auth in monitor so it expects 200 when authed
target_name_logs = "Dozzle UI (auth)"
if target_name_logs in existing:
    m = existing[target_name_logs]
    api.edit_monitor(
        m["id"],
        type=MonitorType.HTTP,
        name=target_name_logs,
        url="https://logs.hexwyrm.com/",
        interval=60,
        method="GET",
        expected_status_codes="200-299",
        basic_auth_user="admin",
        basic_auth_pass="P!err391535740P1",
        ignore_tls=True,
    )
    print(f"UPDATED: {target_name_logs}")
else:
    api.add_monitor(
        type=MonitorType.HTTP,
        name=target_name_logs,
        url="https://logs.hexwyrm.com/",
        interval=60,
        method="GET",
        expected_status_codes="200-299",
        basic_auth_user="admin",
        basic_auth_pass="P!err391535740P1",
        interval=60,
        ignore_tls=True,
    )
    print(f"CREATED: {target_name_logs}")

api.logout()
