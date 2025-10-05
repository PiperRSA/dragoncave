#!/usr/bin/env python3
from uptime_kuma_api import UptimeKumaApi
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

api = UptimeKumaApi("https://obs.hexwyrm.com", ssl_verify=False)
api.login("admin", "P!err391535740P1")
monitors = api.get_monitors()
for m in monitors:
    print(f"{m.get('id', '?')}\t{m.get('name')}\t{m.get('type')}\t{m.get('url')}")
api.disconnect()
