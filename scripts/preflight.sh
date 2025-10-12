#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'error: missing required command "%s"\n' "$cmd" >&2
    exit 1
  fi
}

run_yamllint() {
  info "yamllint :: scanning repository"
  require_cmd yamllint
  yamllint -c "${ROOT_DIR}/.yamllint" "${ROOT_DIR}"
}

run_shellcheck() {
  info "shellcheck :: scanning shell scripts"
  require_cmd shellcheck

  local shell_targets=()
  while IFS= read -r file; do
    shell_targets+=("$file")
  done < <(find "${ROOT_DIR}" -type f -name "*.sh" \
    ! -path "*/.git/*" \
    ! -path "*/.venv/*" \
    ! -path "*/venv/*" \
    ! -path "*/node_modules/*")

  if ((${#shell_targets[@]} == 0)); then
    info "shellcheck :: no shell scripts found, skipping"
    return 0
  fi
  shellcheck "${shell_targets[@]}"
}

run_hadolint() {
  info "hadolint :: scanning Dockerfiles"
  require_cmd hadolint

  local dockerfiles=()
  while IFS= read -r file; do
    dockerfiles+=("$file")
  done < <(find "${ROOT_DIR}" -type f \( -name "Dockerfile" -o -name "Dockerfile.*" -o -name "*.Dockerfile" \))

  if ((${#dockerfiles[@]} == 0)); then
    info "hadolint :: no Dockerfiles found, skipping"
    return 0
  fi
  hadolint "${dockerfiles[@]}"
}

info "Dragoncave preflight diagnostics starting"
run_yamllint
run_shellcheck
run_hadolint
info "Dragoncave preflight diagnostics complete"
