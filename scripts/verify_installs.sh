#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="ai-fortune-cookie"

cleanup() {
  if [[ -n "${TMP_ROOT:-}" && -d "${TMP_ROOT}" ]]; then
    rm -rf "${TMP_ROOT}"
  fi
}

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

assert_exists() {
  local path="$1"
  [[ -e "${path}" || -L "${path}" ]] || fail "Expected path to exist: ${path}"
}

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || fail "Expected file to exist: ${path}"
}

assert_symlink() {
  local path="$1"
  [[ -L "${path}" ]] || fail "Expected symlink: ${path}"
}

runtime_copy() {
  local dest="$1"
  mkdir -p "${dest}/agents" "${dest}/scripts" "${dest}/references"
  cp "${REPO_DIR}/install.sh" "${dest}/"
  cp "${REPO_DIR}/SKILL.md" "${dest}/"
  cp "${REPO_DIR}/agents/openai.yaml" "${dest}/agents/"
  cp "${REPO_DIR}/scripts/context_snapshot.py" "${dest}/scripts/"
  cp "${REPO_DIR}/references/fortune-patterns.md" "${dest}/references/"
}

test_copy_host() {
  local host="$1"
  local env_name="$2"
  local home_root="$3"

  echo "[test] copy install: ${host}"
  env "${env_name}=${home_root}" "${REPO_DIR}/install.sh" --host "${host}" --force
  assert_file "${home_root}/skills/${SKILL_NAME}/SKILL.md"
  assert_file "${home_root}/skills/${SKILL_NAME}/agents/openai.yaml"
  assert_file "${home_root}/skills/${SKILL_NAME}/scripts/context_snapshot.py"
  assert_file "${home_root}/skills/${SKILL_NAME}/references/fortune-patterns.md"
}

test_symlink_host() {
  local host="$1"
  local env_name="$2"
  local home_root="$3"

  echo "[test] symlink install: ${host}"
  env "${env_name}=${home_root}" "${REPO_DIR}/install.sh" --host "${host}" --symlink --force
  assert_symlink "${home_root}/skills/${SKILL_NAME}"
}

test_in_place_host() {
  local host="$1"
  local env_name="$2"
  local hidden_root="$3"
  local install_root="${hidden_root}/skills/${SKILL_NAME}"
  local output

  echo "[test] in-place install detection: ${host}"
  runtime_copy "${install_root}"
  output="$(
    env "${env_name}=${hidden_root}" "${install_root}/install.sh" --host "${host}" --force
  )"
  [[ "${output}" == *"already installed in-place"* ]] || fail "Expected in-place message for ${host}"
  assert_file "${install_root}/SKILL.md"
  assert_file "${install_root}/agents/openai.yaml"
}

test_cursor_copy() {
  local project_root="$1"

  echo "[test] copy install: cursor"
  mkdir -p "${project_root}"
  "${REPO_DIR}/install.sh" --host cursor --project "${project_root}" --force
  assert_file "${project_root}/.cursor/rules/${SKILL_NAME}.mdc"
}

test_cursor_symlink() {
  local project_root="$1"

  echo "[test] symlink install: cursor"
  mkdir -p "${project_root}"
  "${REPO_DIR}/install.sh" --host cursor --project "${project_root}" --symlink --force
  assert_symlink "${project_root}/.cursor/rules/${SKILL_NAME}.mdc"
}

test_host_all() {
  local codex_root="$1"
  local claude_root="$2"
  local gemini_root="$3"
  local cursor_project="$4"

  echo "[test] install all hosts"
  mkdir -p "${cursor_project}"
  env \
    CODEX_HOME="${codex_root}" \
    CLAUDE_HOME="${claude_root}" \
    GEMINI_HOME="${gemini_root}" \
    "${REPO_DIR}/install.sh" --host all --project "${cursor_project}" --force

  assert_file "${codex_root}/skills/${SKILL_NAME}/SKILL.md"
  assert_file "${claude_root}/skills/${SKILL_NAME}/SKILL.md"
  assert_file "${gemini_root}/skills/${SKILL_NAME}/SKILL.md"
  assert_file "${cursor_project}/.cursor/rules/${SKILL_NAME}.mdc"
}

main() {
  TMP_ROOT="$(mktemp -d /tmp/ai-fortune-cookie-verify.XXXXXX)"
  trap cleanup EXIT

  bash -n "${REPO_DIR}/install.sh"

  test_copy_host "codex" "CODEX_HOME" "${TMP_ROOT}/copy-codex-home"
  test_copy_host "claude" "CLAUDE_HOME" "${TMP_ROOT}/copy-claude-home"
  test_copy_host "gemini" "GEMINI_HOME" "${TMP_ROOT}/copy-gemini-home"
  test_cursor_copy "${TMP_ROOT}/copy-cursor-project"

  test_symlink_host "codex" "CODEX_HOME" "${TMP_ROOT}/link-codex-home"
  test_symlink_host "claude" "CLAUDE_HOME" "${TMP_ROOT}/link-claude-home"
  test_symlink_host "gemini" "GEMINI_HOME" "${TMP_ROOT}/link-gemini-home"
  test_cursor_symlink "${TMP_ROOT}/link-cursor-project"

  test_in_place_host "codex" "CODEX_HOME" "${TMP_ROOT}/in-place-codex/.codex"
  test_in_place_host "claude" "CLAUDE_HOME" "${TMP_ROOT}/in-place-claude/.claude"
  test_in_place_host "gemini" "GEMINI_HOME" "${TMP_ROOT}/in-place-gemini/.gemini"

  test_host_all \
    "${TMP_ROOT}/all-codex-home" \
    "${TMP_ROOT}/all-claude-home" \
    "${TMP_ROOT}/all-gemini-home" \
    "${TMP_ROOT}/all-cursor-project"

  echo "[ok] all installer checks passed"
}

main "$@"
