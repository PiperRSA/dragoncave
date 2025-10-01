Got it — here’s the full README in a single block so you can copy it straight into nano:

# 🐉 Dragoncave Homelab

This repository contains the Docker Compose stacks and configuration files for **Dragoncave**, my Raspberry Pi homelab environment.

---

## 📍 System Overview
- **Host:** `dragoncave` (Raspberry Pi 5, 16GB RAM)
- **Domain:** `hexwyrm.com`
- **OS:** Debian Bookworm (64-bit)
- **Reverse Proxy:** Traefik v3.1.4

---

## 📂 Repository Layout

stacks/
└── edge-traefik.yml   → Traefik reverse proxy (main entrypoint for the lab)

configs/traefik/
└── dynamic.yml        → Dynamic Traefik configuration
- Dashboard (traefik.hexwyrm.com/dashboard)
- API (traefik.hexwyrm.com/api)
- Root redirect → /dashboard/
- Test route (/test → whoami)

.gitignore               → Ensures secrets and sensitive files are not committed
.env.example             → Example environment variables
README.md                → Project documentation

---

## 🚀 Deployment Instructions

1. **Clone this repo (already done on dragoncave):**
   ```bash
   git clone https://github.com/PiperRSA/dragoncave.git /opt/dragoncave/git/dragoncave
   cd /opt/dragoncave/git/dragoncave

	2.	Set up environment variables:
Copy the example env file:

cp .env.example /opt/dragoncave/.env.dragoncave

Edit it with your real values (e.g. domain, email, etc.).

	3.	Run the stack:

docker compose -f stacks/edge-traefik.yml --env-file /opt/dragoncave/.env.dragoncave up -d


	4.	Check logs and status:

docker ps
docker logs -f edge-traefik



⸻

🔒 Secrets
	•	Secrets are stored in:
/opt/dragoncave/secrets/
	•	Example:
	•	TRAEFIK_BASIC_AUTH → stores BasicAuth credentials for dashboard/API
	•	These are not committed to GitHub thanks to .gitignore.

⸻

✅ Current Features
	•	Traefik v3.1.4 running as reverse proxy
	•	Dashboard & API available at:
	•	https://traefik.hexwyrm.com/dashboard/
	•	https://traefik.hexwyrm.com/api/rawdata
	•	BasicAuth enabled (dragon:<password> from secrets file)
	•	Root redirect: https://traefik.hexwyrm.com/ → /dashboard/
	•	Test Service:
	•	https://whoami.hexwyrm.com → routed to the whoami container

⸻

🛠 Next Steps
	•	Add Portainer (portainer.hexwyrm.com)
	•	Add Pi-hole for DNS/ad-blocking (pihole.hexwyrm.com)
	•	Add Watchtower for automatic container updates
	•	Set up Cloudflare Tunnel for external HTTPS access
	•	Expand dynamic Traefik config with additional stacks

⸻

📌 Managed from dragoncave @ 192.168.68.145

---

👉 Next step:  

```bash
nano /opt/dragoncave/git/dragoncave/README.md

Paste this entire block, save, exit, then we’ll git add/commit/push.

Do you want me to also prepare the .gitignore text block so you can add that right after?
