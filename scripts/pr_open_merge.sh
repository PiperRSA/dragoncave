#!/usr/bin/env bash
set -euo pipefail
REPO_SLUG="${REPO_SLUG:-PiperRSA/dragoncave}"
PR_BRANCH="${PR_BRANCH:-sync/pi-master-2025-10-12}"
TITLE="${TITLE:-Sync: Pi-Side Updates (12 Oct 2025)}"
MERGE_FLAG="${1:-}"
have_gh() { command -v gh >/dev/null 2>&1; }
need_token() { [ -n "${GITHUB_TOKEN:-}" ]; }
if have_gh; then
  gh auth status >/dev/null 2>&1 || { echo "ERROR: gh not authenticated"; exit 1; }
  PR_URL="$(gh pr view --repo "$REPO_SLUG" "$PR_BRANCH" --json url -q .url 2>/dev/null || true)"
  if [ -z "$PR_URL" ]; then
    PR_URL="$(gh pr create --repo "$REPO_SLUG" --base main --head "$PR_BRANCH" --title "$TITLE" --body "Automated script")"
  fi
  echo "PR: $PR_URL"
  gh pr ready "$PR_BRANCH" --repo "$REPO_SLUG" >/dev/null 2>&1 || true
  if [ "$MERGE_FLAG" = "--merge" ]; then
    gh pr merge "$PR_BRANCH" --repo "$REPO_SLUG" --merge --title "Merge: sync(pi) into main" --body "Automated via script"
  fi
  exit 0
fi
if ! need_token; then echo "ERROR: Set GITHUB_TOKEN for API fallback"; exit 1; fi
owner="${REPO_SLUG%%/*}"
PRS="$(curl -sS -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$REPO_SLUG/pulls?state=open&head=${owner}:${PR_BRANCH}&base=main")"
PR_NUM="$(
  PRS_JSON="$PRS" python3 - <<'PY'
import json
import os

payload = os.environ.get("PRS_JSON") or "[]"
data = json.loads(payload)
print(data[0]["number"] if data else "")
PY
)"
if [ -z "$PR_NUM" ]; then
  CREATE_PAYLOAD="$(python3 - <<'PY'
import json
import os

print(json.dumps({
    "title": os.environ.get("TITLE"),
    "head": os.environ.get("PR_BRANCH"),
    "base": "main",
    "draft": False
}))
PY
)"
  CREATE_RESP="$(curl -sS -X POST -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$REPO_SLUG/pulls" \
    -d "$CREATE_PAYLOAD")"
  PR_NUM="$(
    RESPONSE_JSON="$CREATE_RESP" python3 - <<'PY'
import json
import os

data = json.loads(os.environ.get("RESPONSE_JSON") or "{}")
print(data.get("number", ""))
PY
  )"
fi
[ -n "$PR_NUM" ] || { echo "ERROR: could not open PR"; exit 1; }
echo "PR: https://github.com/$REPO_SLUG/pull/$PR_NUM"
curl -sS -X PATCH -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$REPO_SLUG/pulls/$PR_NUM" -d '{"draft":false}' >/dev/null
if [ "$MERGE_FLAG" = "--merge" ]; then
  curl -sS -X PUT -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$REPO_SLUG/pulls/$PR_NUM/merge" \
    -d '{"merge_method":"merge","commit_title":"Merge: sync(pi) into main","commit_message":"Automated via script"}' >/dev/null
fi
