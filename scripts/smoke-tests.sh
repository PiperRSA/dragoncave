#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/dragoncave"
ENV_FILE="${BASE_DIR}/.env.dragoncave"
if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

PUBLIC_DOMAIN="${PUBLIC_DOMAIN:-hexwyrm.com}"
INTERNAL_DOMAIN="${INTERNAL_DOMAIN:-hexwyrm.home.arpa}"
PI_HOST_IP="${PI_HOST_IP:-127.0.0.1}"
MODE="${1:---summary}"

HTTP_CHECKS=(
  "Traefik|https://traefik.${PUBLIC_DOMAIN}|401"
  "Portainer|https://portainer.${PUBLIC_DOMAIN}|401"
  "Pi-hole|https://pihole.${PUBLIC_DOMAIN}|200,401,302"
  "Observability|https://obs.${PUBLIC_DOMAIN}|200,302"
  "Uptime Kuma|https://uptime.${PUBLIC_DOMAIN}|200,302"
  "Dozzle|https://logs.${PUBLIC_DOMAIN}|200,401,302"
  "Node-RED|https://flows.${PUBLIC_DOMAIN}|200,302"
  "n8n|https://workflows.${PUBLIC_DOMAIN}|200,302"
  "Meilisearch|https://search.${PUBLIC_DOMAIN}|200,401,403"
)

DNS_CHECKS=(
  "Internal Traefik|traefik.${INTERNAL_DOMAIN}|${PI_HOST_IP}"
  "Internal Portainer|portainer.${INTERNAL_DOMAIN}|${PI_HOST_IP}"
  "Internal Pi-hole|pihole.${INTERNAL_DOMAIN}|${PI_HOST_IP}"
)

CONTAINER_CHECKS=(
  "edge-traefik"
  "cloudflared"
  "portainer"
  "pihole"
  "loki"
  "grafana"
  "uptime-kuma"
  "dozzle"
)

colour() {
  local code="$1"; shift || true
  printf "\033[%sm%s\033[0m" "${code}" "$*"
}

http_check() {
  local name="$1" url="$2" expected="$3"
  local result="000"
  if command -v curl >/dev/null 2>&1; then
    result="$(curl -skL -o /dev/null -w '%{http_code}' "${url}" || echo "000")"
  fi
  IFS=',' read -r -a codes <<<"${expected}"
  local status="FAIL"
  for code in "${codes[@]}"; do
    if [[ "${result}" == "${code}" ]]; then
      status="PASS"
      break
    fi
  done
  printf "%-18s %-45s %-8s %s\n" "${name}" "${url}" "${result}" "${status}"
  [[ "${status}" == "PASS" ]]
}

dns_check() {
  local name="$1" host="$2" expected_ip="$3"
  local actual=""
  if command -v getent >/dev/null 2>&1; then
    actual="$(getent hosts "${host}" | awk '{print $1}' | head -n1)"
  else
    actual="$(dig +short "${host}" 2>/dev/null | head -n1)"
  fi
  local status="FAIL"
  if [[ -n "${actual}" && "${actual}" == "${expected_ip}" ]]; then
    status="PASS"
  fi
  printf "%-18s %-45s %-8s %s\n" "${name}" "${host}" "${actual:-N/A}" "${status}"
  [[ "${status}" == "PASS" ]]
}

container_status() {
  local name="$1"
  local status
  status="$(docker ps --format '{{.Names}} {{.Status}}' | awk -v n="${name}" '$1==n {print $2" "$3" "$4}')"
  if [[ -z "${status}" ]]; then
    printf "%-18s %-45s %-8s %s\n" "${name}" "container" "missing" "FAIL"
    return 1
  fi
  printf "%-18s %-45s %-8s %s\n" "${name}" "container" "${status}" "PASS"
  return 0
}

print_header() {
  printf "\n%-18s %-45s %-8s %s\n" "CHECK" "TARGET" "RESULT" "STATUS"
  printf "%-18s %-45s %-8s %s\n" "------------------" "---------------------------------------------" "--------" "------"
}

summary() {
  local ok=true
  print_header
  for entry in "${HTTP_CHECKS[@]}"; do
    IFS='|' read -r name url codes <<<"${entry}"
    http_check "${name}" "${url}" "${codes}" || ok=false
  done
  for entry in "${DNS_CHECKS[@]}"; do
    IFS='|' read -r name host ip <<<"${entry}"
    dns_check "${name}" "${host}" "${ip}" || ok=false
  done
  for name in "${CONTAINER_CHECKS[@]}"; do
    container_status "${name}" || ok=false
  done
  if ${ok}; then
    colour 32 "\nAll smoke tests passed."
    printf "\n"
    return 0
  else
    colour 31 "\nOne or more smoke tests failed."
    printf "\n"
    return 1
  fi
}

status() {
  summary || true
  printf "\nDocker summary:\n"
  docker ps --format '  - {{.Names}} -> {{.Status}}' | sort || true
  printf "\nNetworks:\n"
  docker network ls --format '  - {{.Name}}' | sort || true
}

case "${MODE}" in
  --summary)
    summary
    ;;
  --status)
    status
    ;;
  --json)
    summary >/tmp/smoke.txt || true
    awk '{print}' /tmp/smoke.txt
    ;;
  *)
    summary
    ;;
esac
