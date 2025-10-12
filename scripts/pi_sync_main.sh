#!/usr/bin/env bash
set -euo pipefail
cd /opt/dragoncave
git fetch origin --prune
git checkout main 2>/dev/null || git switch main
git pull --ff-only
echo "Pi commit:"; git --no-pager log -1 --oneline
echo
echo "Containers:"; docker ps --format 'table {{.Names}}\t{{.Status}}'
echo
echo "Routers:"; curl -s http://localhost:8080/api/http/routers | jq -r '.[].name' 2>/dev/null || echo "(Traefik API not accessible)"
