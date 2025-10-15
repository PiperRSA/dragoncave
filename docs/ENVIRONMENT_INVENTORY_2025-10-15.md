# Dragoncave Host Inventory — 2025-10-15

## Host Snapshot
- **Hostname / Kernel:** `dragoncave` · `Linux 6.12.34+rpt-rpi-2712 aarch64`
- **OS:** Debian Bookworm (64-bit) on Raspberry Pi 5
- **Docker:** Engine installed; all containers/images/volumes/networks removed (clean baseline).
- **Repository:** `/opt/dragoncave/git/dragoncave` tracking branch `codex/installer-20251015`.

## Mounted Storage
| Mount | Device | FSType | Label | Size | Used | Free | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `/` | `/dev/mmcblk0p2` | ext4 | rootfs | 117 G | 6.7 G | 105 G | OS volume |
| `/boot/firmware` | `/dev/mmcblk0p1` | vfat | bootfs | 510 M | 74 M | 437 M | Boot partition |
| `/mnt/Hoard1` | `/dev/nvme0n1p1` | ext4 | Hoard1 | 916 G | ~0 G | 870 G | Also mounted at `/media/Hoard1` |
| `/mnt/Hoard2` | `/dev/nvme1n1p1` | ext4 | Hoard2 | 916 G | ~0 G | 870 G | Also mounted at `/media/Hoard2` |
| `/mnt/vault3` | `/dev/sda1` | exFAT | Vault3 | 954 G | 78 G | 877 G | uid/gid 1000, backup media |

## `/opt/dragoncave` Usage
| Path | Size | Notes |
| --- | --- | --- |
| `/opt/dragoncave` | 68 M | Working tree + configs |
| `/opt/dragoncave/configs` | 26 M | Service configuration templates |
| `/opt/dragoncave/git` | 3.7 M | Git checkout (branch `codex/installer-20251015`) |
| `/opt/dragoncave/storage` | 148 K | Local override dirs for Hoard/Vault (empty scaffolding) |
| `/opt/dragoncave/logs` | 116 K | Installer logs |
| `/opt/dragoncave/secrets` | 140 K | Required secret files populated 2025-10-15 |
| `/opt/dragoncave/scripts` | 16 K | Utility scripts (install, smoke-tests, etc.) |
| `/opt/dragoncave/data` | 44 K | Empty scaffold |
| `/opt/dragoncave/venv` | 30 M | Python virtualenv (preflight tooling) |

### Secrets Present (`/opt/dragoncave/secrets`)
`cloudflare.env`, `CF_TUNNEL_TOKEN`, hashed `traefik_basicauth.htpasswd`, and 20 service-specific credentials generated on 2025-10-15 with correct ownership/mode (`0400`). These align with `secrets/README.md`.

## Hoard1 (`/mnt/Hoard1`)
Top-level usage (all ≤ 48 KB; effectively empty placeholders):
- `apps/`, `databases/`, `observability/`, `search/` — scaffolding for future workloads.
- `letsencrypt/` — empty ACME storage.
- `compose/` — archival Docker compose snippets (48 KB).

## Hoard2 (`/mnt/Hoard2`)
Top-level usage (all negligible):
- `data/` (84 KB) — legacy scratch data.
- `nextcloud/`, `paperless/`, `immich/`, `minio/` — freshly created bind mount roots.
- `lost+found/` — filesystem default.

## Vault3 (`/mnt/vault3`)
| Path | Size | Description |
| --- | --- | --- |
| `tomes/` | 77 G | Personal media/archive content (retained). |
| `dragoncave-backups/` | 60 M | Historic Dragoncave backups (retain). |
| `restic/` | 128 K | Restic repository scaffold. |
| `.Spotlight-V100/`, `.fseventsd/` | 650 M | macOS metadata (expected on exFAT). |

## Docker State
- All containers stopped and removed (`docker ps -a` reports none).
- All images deleted; `docker images` returns empty list.
- All volumes pruned; no custom networks (`bridge/host/none` only).
- Build cache/system prune executed; working baseline ready for redeploy.

## Next Steps
1. Re-run installer once configuration decisions are finalised.
2. When ready to use Hoard mounts, update `/opt/dragoncave/.env.dragoncave` storage paths and ensure UID/GID ownership matches stack expectations.
3. Restore tunnel health by redeploying `tunnel-cloudflared.yml` after re-running installer.
