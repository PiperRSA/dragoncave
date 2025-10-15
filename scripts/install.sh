#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/dragoncave"
REPO_DIR="${BASE_DIR}/git/dragoncave"
ENV_FILE="${BASE_DIR}/.env.dragoncave"
SECRETS_DIR="${BASE_DIR}/secrets"
LOG_DIR="${BASE_DIR}/logs"
LOG_FILE="${LOG_DIR}/installer.log"
REPO_URL="${DRAGONCAVE_REPO_URL:-https://github.com/PiperRSA/dragoncave.git}"
REQUIRED_NETWORKS=("edge" "core" "dns")
DEFAULT_STACKS=("sec-docker-socket-proxy.yml" "edge-traefik.yml" "tunnel-cloudflared.yml" "portainer.yml" "dns-pihole.yml" "obs-logs.yml" "obs-exporters.yml" "obs-monitoring.yml" "obs-watchtower.yml" "data-services.yml")
TARGET_BRANCH="${DRAGONCAVE_BRANCH:-main}"
ACTION="install"
PLAN_MODE=false

colour() {
  local code="$1"; shift || true
  printf "\033[%sm%s\033[0m" "${code}" "$*"
}

now()   { date '+%Y-%m-%d %H:%M:%S'; }
log()   { printf "[%s] %s\n" "$(now)" "$(colour '32' "$*")"; }
warn()  { printf "[%s] %s\n" "$(now)" "$(colour '33' "$*")"; }
err()   { printf "[%s] %s\n" "$(now)" "$(colour '31' "$*")" >&2; }
fatal() { err "$*"; exit 1; }

init_logging() {
  mkdir -p "${LOG_DIR}"
  touch "${LOG_FILE}"
  exec > >(tee -a "${LOG_FILE}") 2>&1
}

set_action() {
  local new_action="$1"
  if [[ "${ACTION}" != "install" && "${ACTION}" != "${new_action}" ]]; then
    fatal "Multiple actions requested (${ACTION} vs ${new_action})."
  fi
  ACTION="${new_action}"
}

parse_args() {
  while (($#)); do
    case "$1" in
      --branch=*)
        TARGET_BRANCH="${1#*=}"
        ;;
      --branch)
        shift
        if (($# == 0)); then
          fatal "--branch requires a value"
        fi
        TARGET_BRANCH="$1"
        ;;
      --plan|plan)
        PLAN_MODE=true
        set_action "plan"
        ;;
      --status|--upgrade|--reset-soft|--reset-hard|--uninstall|install)
        set_action "$1"
        ;;
      --help|-h)
        set_action "--help"
        ;;
      *)
        fatal "Unknown argument: $1"
        ;;
    esac
    shift || true
  done
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    fatal "This script must run as root (sudo)."
  fi
}

check_arch() {
  local arch
  arch="$(uname -m)"
  if [[ "${arch}" != "aarch64" ]]; then
    warn "Expected Raspberry Pi 5 (aarch64); detected '${arch}'. Proceeding anyway."
  fi
}

ensure_packages() {
  local pkgs=(curl git jq docker.io docker-compose-plugin docker-buildx-plugin)
  if ! command -v docker >/dev/null 2>&1; then
    apt-get update -qq
  fi
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
  systemctl enable docker >/dev/null 2>&1 || true
  systemctl start docker >/dev/null 2>&1 || true
}

checkout_target_branch() {
  if git -C "${REPO_DIR}" show-ref --verify --quiet "refs/heads/${TARGET_BRANCH}"; then
    git -C "${REPO_DIR}" checkout "${TARGET_BRANCH}" >/dev/null 2>&1 \
      || git -C "${REPO_DIR}" switch "${TARGET_BRANCH}" >/dev/null 2>&1 \
      || fatal "Unable to switch to ${TARGET_BRANCH}"
  elif git -C "${REPO_DIR}" show-ref --verify --quiet "refs/remotes/origin/${TARGET_BRANCH}"; then
    git -C "${REPO_DIR}" checkout -B "${TARGET_BRANCH}" "origin/${TARGET_BRANCH}" >/dev/null 2>&1 \
      || fatal "Unable to create local branch ${TARGET_BRANCH}"
  else
    fatal "Branch ${TARGET_BRANCH} not found on origin"
  fi
}

clone_or_update_repo() {
  mkdir -p "$(dirname "${REPO_DIR}")"
  if [[ -d "${REPO_DIR}/.git" ]]; then
    log "Syncing repository at ${REPO_DIR} (branch ${TARGET_BRANCH})"
    git -C "${REPO_DIR}" fetch origin --prune
    checkout_target_branch
    git -C "${REPO_DIR}" pull --ff-only origin "${TARGET_BRANCH}"
  else
    log "Cloning repository branch ${TARGET_BRANCH} to ${REPO_DIR}"
    git clone --branch "${TARGET_BRANCH}" --single-branch "${REPO_URL}" "${REPO_DIR}"
  fi
}

ensure_env_file() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    log "Creating ${ENV_FILE} from example"
    install -m 640 "${REPO_DIR}/.env.dragoncave.example" "${ENV_FILE}"
  fi
}

load_env() {
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
}

load_env_optional() {
  if [[ -r "${ENV_FILE}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +a
    return 0
  fi
  warn "Environment file ${ENV_FILE} missing or unreadable; continuing with defaults."
  return 1
}

ensure_dir() {
  local path="$1" mode="$2" owner="$3" group="$4"
  install -d -m "${mode}" -o "${owner}" -g "${group}" "${path}"
}

detect_storage_path() {
  local var_name="$1" default_path="$2" label="$3"
  local current_value="${!var_name:-}"
  if [[ -n "${current_value}" && -d "${current_value}" ]]; then
    return
  fi
  local detected
  detected="$(lsblk -rno MOUNTPOINT,LABEL | awk -v label="${label}" '$2==label {print $1; exit}')"
  if [[ -n "${detected}" ]]; then
    printf -v "${var_name}" '%s' "${detected}"
    warn "Detected ${label} mounted at ${detected}"
  else
    warn "Could not find ${label}; defaulting to ${default_path}"
    printf -v "${var_name}" '%s' "${default_path}"
  fi
}

update_env_var() {
  local key="$1" value="$2"
  local tmp="${ENV_FILE}.tmp"
  if [[ -f "${ENV_FILE}" ]]; then
    grep -v "^${key}=" "${ENV_FILE}" > "${tmp}" || true
  fi
  printf '%s=%s\n' "${key}" "${value}" >> "${tmp}"
  install -m 640 "${tmp}" "${ENV_FILE}"
  rm -f "${tmp}"
}

prepare_storage() {
  detect_storage_path HOARD1_ROOT "${BASE_DIR}/storage/hoard1" Hoard1
  detect_storage_path HOARD2_ROOT "${BASE_DIR}/storage/hoard2" Hoard2
  detect_storage_path VAULT3_ROOT "${BASE_DIR}/storage/vault3" Vault3

  local hoard1_dirs=(
    "${HOARD1_ROOT}:0750:0:0"
    "${HOARD1_ROOT}/letsencrypt:0750:0:0"
    "${HOARD1_ROOT}/databases:0750:0:0"
    "${HOARD1_ROOT}/databases/postgres:0750:0:0"
    "${HOARD1_ROOT}/databases/postgres/shared:0750:999:999"
    "${HOARD1_ROOT}/databases/postgres/paperless:0750:999:999"
    "${HOARD1_ROOT}/databases/postgres/nextcloud:0750:999:999"
    "${HOARD1_ROOT}/databases/postgres/immich:0750:999:999"
    "${HOARD1_ROOT}/databases/mariadb:0750:999:999"
    "${HOARD1_ROOT}/databases/redis:0750:1000:1000"
    "${HOARD1_ROOT}/observability:0750:0:0"
    "${HOARD1_ROOT}/observability/loki:0750:1000:1000"
    "${HOARD1_ROOT}/observability/grafana:0750:1000:1000"
    "${HOARD1_ROOT}/observability/kuma:0750:1000:1000"
    "${HOARD1_ROOT}/observability/promtail:0750:0:0"
    "${HOARD1_ROOT}/search:0750:0:0"
    "${HOARD1_ROOT}/search/meili:0750:1000:1000"
    "${HOARD1_ROOT}/apps:0750:0:0"
    "${HOARD1_ROOT}/apps/homeassistant:0750:1000:1000"
    "${HOARD1_ROOT}/apps/gitea:0750:1000:1000"
    "${HOARD1_ROOT}/apps/mosquitto:0750:1000:1000"
    "${HOARD1_ROOT}/apps/influxdb:0750:1000:1000"
    "${HOARD1_ROOT}/apps/vaultwarden:0750:1000:1000"
  )
  local hoard2_dirs=(
    "${HOARD2_ROOT}:0750:0:0"
    "${HOARD2_ROOT}/nextcloud:0750:1000:1000"
    "${HOARD2_ROOT}/paperless:0750:0:0"
    "${HOARD2_ROOT}/paperless/data:0750:1000:1000"
    "${HOARD2_ROOT}/paperless/media:0750:1000:1000"
    "${HOARD2_ROOT}/paperless/consume:0750:1000:1000"
    "${HOARD2_ROOT}/immich:0750:0:0"
    "${HOARD2_ROOT}/immich/photos:0750:1000:1000"
    "${HOARD2_ROOT}/minio:0750:1000:1000"
  )
  local vault_dirs=(
    "${VAULT3_ROOT}:0750:0:0"
    "${VAULT3_ROOT}/restic:0750:0:0"
  )
  local entry dir mode owner group
  for entry in "${hoard1_dirs[@]}"; do
    IFS=':' read -r dir mode owner group <<<"${entry}"
    ensure_dir "${dir}" "${mode}" "${owner}" "${group}"
  done
  for entry in "${hoard2_dirs[@]}"; do
    IFS=':' read -r dir mode owner group <<<"${entry}"
    ensure_dir "${dir}" "${mode}" "${owner}" "${group}"
  done
  for entry in "${vault_dirs[@]}"; do
    IFS=':' read -r dir mode owner group <<<"${entry}"
    ensure_dir "${dir}" "${mode}" "${owner}" "${group}"
  done
  export HOARD1_ROOT HOARD2_ROOT VAULT3_ROOT
  update_env_var HOARD1_ROOT "${HOARD1_ROOT}"
  update_env_var HOARD2_ROOT "${HOARD2_ROOT}"
  update_env_var VAULT3_ROOT "${VAULT3_ROOT}"
}

ensure_base_directories() {
  local dirs=(stacks configs secrets scripts logs backups certs)
  for dir in "${dirs[@]}"; do
    install -d -m 0755 "${BASE_DIR}/${dir}"
  done
}

prepare_config_dirs() {
  local config_dirs=(
    "${BASE_DIR}/configs/node-red:0755:1000:1000"
    "${BASE_DIR}/configs/n8n:0755:1000:1000"
    "${BASE_DIR}/configs/homeassistant:0755:1000:1000"
    "${BASE_DIR}/configs/mosquitto:0755:1000:1000"
    "${BASE_DIR}/configs/telegraf:0755:1000:1000"
    "${BASE_DIR}/configs/loki:0755:1000:1000"
    "${BASE_DIR}/configs/grafana:0755:1000:1000"
    "${BASE_DIR}/configs/cloudflared:0755:1000:1000"
    "${BASE_DIR}/configs/promtail:0755:0:0"
    "${BASE_DIR}/configs/pihole:0755:0:0"
    "${BASE_DIR}/configs/pihole/etc-pihole:0755:0:0"
    "${BASE_DIR}/configs/pihole/etc-dnsmasq.d:0755:0:0"
  )
  local entry dir mode owner group
  for entry in "${config_dirs[@]}"; do
    IFS=':' read -r dir mode owner group <<<"${entry}"
    ensure_dir "${dir}" "${mode}" "${owner}" "${group}"
  done
}

discover_required_secrets() {
  local files
  if [[ ! -d "${REPO_DIR}/stacks" ]]; then
    REQUIRED_SECRETS=()
    return
  fi
  local files=()
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    files+=("${line}")
  done < <(grep -R "/opt/dragoncave/secrets/" "${REPO_DIR}/stacks" -h \
    | sed -E 's/.*\/opt\/dragoncave\/secrets\/([^":[:space:]]+).*/\1/' \
    | cut -d':' -f1 \
    | sort -u)
  REQUIRED_SECRETS=("${files[@]}")
}

wait_for_secrets() {
  discover_required_secrets
  if [[ ${#REQUIRED_SECRETS[@]} -eq 0 ]]; then
    warn "No secrets discovered; skipping gate."
    return
  fi
  log "Secrets required for deployment:"
  printf '  - %s\n' "${REQUIRED_SECRETS[@]}"
  warn "Hint: run ${REPO_DIR}/scripts/secrets-bootstrap.sh --fill to scaffold missing secret files."
  while true; do
    local missing=()
    for secret in "${REQUIRED_SECRETS[@]}"; do
      if [[ ! -s "${SECRETS_DIR}/${secret}" ]]; then
        missing+=("${secret}")
      fi
    done
    if (( ${#missing[@]} == 0 )); then
      log "All secrets present."
      break
    fi
    warn "Missing secrets: ${missing[*]}"
    read -r -p "Create the missing files under ${SECRETS_DIR} then press Enter to continue..." _
  done
}

ensure_networks() {
  for net in "${REQUIRED_NETWORKS[@]}"; do
    if ! docker network inspect "${net}" >/dev/null 2>&1; then
      log "Creating docker network: ${net}"
      docker network create "${net}" >/dev/null
    fi
  done
}

stack_project_name() {
  local file="$1"
  local name="${file##*/}"
  name="${name%.*}"
  name="${name//[^a-zA-Z0-9]/-}"
  printf 'dragoncave-%s' "${name,,}"
}

compose_cmd() {
  local file="$1"
  shift
  docker compose \
    --project-name "$(stack_project_name "${file}")" \
    --env-file "${ENV_FILE}" \
    -f "${REPO_DIR}/stacks/${file}" \
    "$@"
}

resolve_stack_list() {
  local stacks=()
  if [[ -n "${ENABLED_STACKS:-}" ]]; then
    read -r -a stacks <<<"${ENABLED_STACKS}"
  else
    stacks=("${DEFAULT_STACKS[@]}")
  fi
  printf '%s\n' "${stacks[@]}"
}

deploy_stack() {
  local stack="$1"
  shift
  local verb="$1"
  shift || true
  log "${verb^} stack: ${stack}"
  if ! compose_cmd "${stack}" config >/dev/null; then
    fatal "Failed to render compose config for ${stack}"
  fi
  local attempts=0
  local max_attempts=3
  while (( attempts < max_attempts )); do
    if compose_cmd "${stack}" "${verb}" "$@"; then
      return 0
    fi
    attempts=$((attempts + 1))
    warn "Retry ${attempts}/${max_attempts} for ${stack}"
    sleep $((2 * attempts))
  done
  fatal "Stack ${stack} failed to ${verb}"
}

deploy_stacks() {
  local stacks=()
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    stacks+=("${line}")
  done < <(resolve_stack_list)
  log "Deploying stacks: ${stacks[*]}"
  for stack in "${stacks[@]}"; do
    if [[ ! -f "${REPO_DIR}/stacks/${stack}" ]]; then
      warn "Skip missing stack ${stack}"
      continue
    fi
    deploy_stack "${stack}" pull
    deploy_stack "${stack}" up -d
  done
}

run_smoke_tests() {
  bash "${REPO_DIR}/scripts/smoke-tests.sh" --summary || warn "Smoke tests reported issues."
}

show_status() {
  bash "${REPO_DIR}/scripts/smoke-tests.sh" --status
}

upgrade_stacks() {
  log "Upgrading repository and containers"
  git -C "${REPO_DIR}" fetch origin --prune
  checkout_target_branch
  git -C "${REPO_DIR}" pull --ff-only origin "${TARGET_BRANCH}"
  load_env
  prepare_config_dirs
  prepare_storage
  ensure_networks
  deploy_stacks
}

plan_install() {
  log "Planner mode enabled – no changes will be applied."
  if [[ -d "${REPO_DIR}/.git" ]]; then
    if ! git -C "${REPO_DIR}" fetch origin --prune >/dev/null 2>&1; then
      warn "Unable to contact origin for ${REPO_URL}; showing local state only."
    fi
    local local_head remote_head
    local_head="$(git -C "${REPO_DIR}" rev-parse --short HEAD 2>/dev/null || echo "n/a")"
    remote_head="$(git -C "${REPO_DIR}" rev-parse --short "origin/${TARGET_BRANCH}" 2>/dev/null || echo "n/a")"
    printf "Repository: %s\n" "${REPO_DIR}"
    printf "  - branch: %s\n" "${TARGET_BRANCH}"
    printf "  - local head: %s\n" "${local_head}"
    printf "  - remote head: %s\n" "${remote_head}"
  else
    warn "Repository not present at ${REPO_DIR}; installer would clone branch ${TARGET_BRANCH}."
  fi

  load_env_optional || true
  local stacks=()
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    stacks+=("${line}")
  done < <(resolve_stack_list)
  printf "\nStacks scheduled for deployment:\n"
  for stack in "${stacks[@]}"; do
    local status="present"
    if [[ ! -f "${REPO_DIR}/stacks/${stack}" ]]; then
      status="missing"
    fi
    printf "  - %s [%s]\n" "${stack}" "${status}"
  done

  discover_required_secrets
  if (( ${#REQUIRED_SECRETS[@]} == 0 )); then
    warn "No secrets referenced yet; ensure stacks are committed."
  else
    printf "\nSecrets status (under %s):\n" "${SECRETS_DIR}"
    local missing=()
    for secret in "${REQUIRED_SECRETS[@]}"; do
      if [[ -s "${SECRETS_DIR}/${secret}" ]]; then
        printf "  - %s [OK]\n" "${secret}"
      else
        printf "  - %s [MISSING]\n" "${secret}"
        missing+=("${secret}")
      fi
    done
    if ((${#missing[@]})); then
      warn "Missing secrets: ${missing[*]}"
    else
      log "All referenced secrets present."
    fi
  fi

  printf "\nDry run complete. Re-run without --plan to execute.\n"
}

reset_soft() {
  load_env
  local stacks=()
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    stacks+=("${line}")
  done < <(resolve_stack_list)
  for stack in "${stacks[@]}"; do
    if [[ -f "${REPO_DIR}/stacks/${stack}" ]]; then
      compose_cmd "${stack}" down --remove-orphans || true
    fi
  done
  docker system prune -af --volumes
}

reset_hard() {
  read -r -p "Hard reset will stop containers and remove Docker state. Continue? [y/N] " answer
  if [[ "${answer}" != [Yy]* ]]; then
    warn "Aborting hard reset."
    return
  fi
  reset_soft
  docker volume prune -f || true
  docker network prune -f || true
}

uninstall_all() {
  reset_soft
  local archive_dir="/opt/archive"
  install -d -m 0755 "${archive_dir}"
  local stamp
  stamp="$(date '+%Y%m%d-%H%M%S')"
  tar -czf "${archive_dir}/dragoncave-${stamp}.tgz" -C /opt dragoncave
  log "Archived /opt/dragoncave to ${archive_dir}/dragoncave-${stamp}.tgz"
  rm -rf /opt/dragoncave
}

main_install() {
  require_root
  check_arch
  ensure_packages
  ensure_base_directories
  prepare_config_dirs
  clone_or_update_repo
  ensure_env_file
  load_env
  prepare_storage
  wait_for_secrets
  ensure_networks
  deploy_stacks
  run_smoke_tests
  show_status
}

parse_args "$@"

if [[ "${PLAN_MODE}" != true ]]; then
  case "${ACTION}" in
    install|--upgrade|--reset-soft|--reset-hard|--uninstall)
      init_logging
      ;;
    *)
      :
      ;;
  esac
fi

case "${ACTION}" in
  --status)
    load_env 2>/dev/null || true
    show_status
    ;;
  --upgrade)
    require_root
    ensure_packages
    clone_or_update_repo
    upgrade_stacks
    run_smoke_tests
    ;;
  --reset-soft)
    require_root
    reset_soft
    ;;
  --reset-hard)
    require_root
    reset_hard
    ;;
  --uninstall)
    require_root
    uninstall_all
    ;;
  --help|-h)
    cat <<'EOF'
Usage: install.sh [--plan] [--branch <name>] [--status|--upgrade|--reset-soft|--reset-hard|--uninstall]
Default (no flag) performs idempotent installation/upgrade with diagnostics.

Options:
  --plan             Dry-run summary; no changes applied.
  --branch <name>    Target git branch (env: DRAGONCAVE_BRANCH, default main).
  --status           Show container status and smoke-test summary.
  --upgrade          Refresh repository, redeploy stacks, run smoke tests.
  --reset-soft       Stop stacks and prune Docker images/containers.
  --reset-hard       Reset Docker state (includes volumes and networks).
  --uninstall        Archive and remove /opt/dragoncave.
EOF
    ;;
  plan|--plan)
    plan_install
    ;;
  install|*)
    main_install
    ;;
esac
