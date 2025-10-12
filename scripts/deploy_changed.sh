#!/usr/bin/env bash
set -euo pipefail
cd /opt/dragoncave
git fetch origin --prune
BASE="origin/main"
CURR="$(git rev-parse --abbrev-ref HEAD || echo HEAD)"
echo "Deploy diff: $BASE .. $CURR"
mapfile -t FILES < <(git diff --name-only "$BASE..$CURR" -- 'stacks/*.yml' 'stacks/*.yaml' | sort -u)
if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No changed stack files to deploy."
  exit 0
fi
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  echo "Applying stack: $f"
  docker compose -f "$f" up -d
done
echo "Done."
