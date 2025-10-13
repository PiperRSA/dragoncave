# Project Instruction

This document gives contributors a quick start for updating Dragoncave while respecting the baseline controls set in Phase 0.

## Working Copy Expectations
- Clone the repository to `~/Projects/dragoncave` for local work; the Raspberry Pi mirrors it under `/opt/dragoncave/git/dragoncave`.
- Keep the working tree clean before switching phases. Run `git status` before and after major edits.
- Use feature branches (`feat/...`) or phase-scoped branches (`phase-<n>/...`) and open PRs against `main`.

## Required Tooling
- Docker Engine + Compose v2
- `yamllint`, `shellcheck`, `hadolint`
- `bash`, `curl`, `jq`, `rg` (ripgrep)
- Optionally `gh` CLI for pull request automation

## Environment Layout
- `/opt/dragoncave/.env.dragoncave` defines shared variables: `PUBLIC_DOMAIN`, `PI_HOST_IP`, `HOARD1_ROOT`, `HOARD2_ROOT`, `VAULT3_ROOT`, exporter settings, and tokens.
- Mount Hoard1 (NVMe) at `${HOARD1_ROOT}` (default `/srv/hoard1`) for databases and observability data; Hoard2 at `${HOARD2_ROOT}` for large content; Vault3 at `${VAULT3_ROOT}` for restic backups.
- Keep `/opt/dragoncave/{configs,secrets,scripts,stacks}` on the OS drive for fast edits and version control.

## Development Workflow
1. Create or update documentation first; each phase must describe its architecture, security, and recovery decisions.
2. Implement stack changes under `stacks/` or `configs/`.
3. Run `make preflight` locally. Fix lint errors before pushing.
4. Document outcomes in `CHANGELOG.md` with a dated section.
5. Deploy on the Raspberry Pi using `scripts/deploy_changed.sh` once reviewed.
6. Use `docs/RUNBOOK_VALIDATION_CHECKLIST.md` while executing runbooks to keep procedures current.

## Secrets Handling
- Never commit files from `/opt/dragoncave/secrets`. The `.gitignore` already excludes common patterns; add new names if required.
- Generate credentials locally, copy them to the Raspberry Pi with secure channels (scp or Tailscale), and set ownership/permissions per `docs/SECRETS_TEMPLATE.md`.
- Reference secrets via Docker secrets or environment files, not inline variables.

## Validation & Rollback
- Use `scripts/smoke-tests.sh` after deployments to confirm ingress health.
- Portainer should show containers healthy with the expected restart policy.
- If a deployment fails, roll back by `git checkout` of the affected stack file and re-running `deploy_changed.sh`.

Adhering to these instructions keeps the homelab reproducible and ready for later automation phases.
