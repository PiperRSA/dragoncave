#!/usr/bin/env bash
set -euo pipefail

hosts=(
  traefik.hexwyrm.com
  portainer.hexwyrm.com
  pihole.hexwyrm.com
  uptime.hexwyrm.com
  logs.hexwyrm.com
  obs.hexwyrm.com
  flows.hexwyrm.com
  workflows.hexwyrm.com
  search.hexwyrm.com
  home.hexwyrm.com
  cloud.hexwyrm.com
  docs.hexwyrm.com
  photos.hexwyrm.com
  git.hexwyrm.com
  s3.hexwyrm.com
  vault.hexwyrm.com
)

for host in "${hosts[@]}"; do
  status="000"
  if command -v curl >/dev/null 2>&1; then
    status="$(curl -skI "https://${host}" | awk 'NR==1{print $2}' || true)"
    status="${status:-000}"
  fi
  printf "%-22s -> %s\n" "${host}" "${status}"
done

printf '\nTraefik provider endpoint:\n' >&2
if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  curl -s http://localhost:8080/api/rawdata | jq -r '.provider' || true
else
  echo "(curl or jq not available)" >&2
fi
