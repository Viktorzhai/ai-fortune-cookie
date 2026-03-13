#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install AI Fortune Cookie for Codex, Claude Code, Gemini CLI, or Cursor.

Usage:
  ./install.sh --host codex|claude|gemini|cursor|all [--copy|--symlink] [--force] [--project PATH]

Options:
  --host     Target host. Required.
  --copy     Copy runtime files. This is the default.
  --symlink  Create symlinks instead of copying.
  --force    Replace an existing install.
  --project  Target project path for Cursor installs.
  -h, --help
EOF
}

MODE="copy"
FORCE=0
HOST=""
PROJECT_DIR=""
SKILL_NAME="ai-fortune-cookie"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="${2:-}"
      shift
      ;;
    --copy)
      MODE="copy"
      ;;
    --symlink)
      MODE="symlink"
      ;;
    --force)
      FORCE=1
      ;;
    --project)
      PROJECT_DIR="${2:-}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ensure_removed() {
  local target="$1"

  if [[ -e "${target}" || -L "${target}" ]]; then
    if [[ "${FORCE}" -ne 1 ]]; then
      echo "Install target already exists: ${target}" >&2
      echo "Re-run with --force to replace it." >&2
      exit 1
    fi
    rm -rf "${target}"
  fi
}

copy_skill_runtime() {
  local dest_dir="$1"

  mkdir -p "${dest_dir}"
  cp "${REPO_DIR}/SKILL.md" "${dest_dir}/"

  for item in agents scripts references assets; do
    if [[ -e "${REPO_DIR}/${item}" ]]; then
      cp -R "${REPO_DIR}/${item}" "${dest_dir}/"
    fi
  done
}

install_skill_host() {
  local host_name="$1"
  local dest_root="$2"
  local dest_dir="${dest_root}/${SKILL_NAME}"

  mkdir -p "${dest_root}"
  ensure_removed "${dest_dir}"

  if [[ "${MODE}" == "symlink" ]]; then
    ln -s "${REPO_DIR}" "${dest_dir}"
  else
    copy_skill_runtime "${dest_dir}"
  fi

  echo "Installed ${host_name} skill to ${dest_dir}"
}

install_cursor_rule() {
  local target_project="$1"
  local project_abs
  project_abs="$(cd "${target_project}" && pwd)"
  local dest_dir="${project_abs}/.cursor/rules"
  local dest_file="${dest_dir}/${SKILL_NAME}.mdc"
  local source_file="${REPO_DIR}/targets/cursor/rules/${SKILL_NAME}.mdc"

  mkdir -p "${dest_dir}"
  ensure_removed "${dest_file}"

  if [[ "${MODE}" == "symlink" ]]; then
    ln -s "${source_file}" "${dest_file}"
  else
    cp "${source_file}" "${dest_file}"
  fi

  echo "Installed Cursor rule to ${dest_file}"
}

if [[ -z "${HOST}" ]]; then
  echo "--host is required." >&2
  usage >&2
  exit 1
fi

case "${HOST}" in
  codex)
    install_skill_host "Codex" "${CODEX_HOME:-$HOME/.codex}/skills"
    ;;
  claude)
    install_skill_host "Claude Code" "${CLAUDE_HOME:-$HOME/.claude}/skills"
    ;;
  gemini)
    install_skill_host "Gemini CLI" "${GEMINI_HOME:-$HOME/.gemini}/skills"
    ;;
  cursor)
    if [[ -z "${PROJECT_DIR}" ]]; then
      echo "--project is required for Cursor installs." >&2
      exit 1
    fi
    install_cursor_rule "${PROJECT_DIR}"
    ;;
  all)
    install_skill_host "Codex" "${CODEX_HOME:-$HOME/.codex}/skills"
    install_skill_host "Claude Code" "${CLAUDE_HOME:-$HOME/.claude}/skills"
    install_skill_host "Gemini CLI" "${GEMINI_HOME:-$HOME/.gemini}/skills"
    if [[ -n "${PROJECT_DIR}" ]]; then
      install_cursor_rule "${PROJECT_DIR}"
    else
      echo "Skipped Cursor: pass --project /path/to/project to install the Cursor rule."
    fi
    ;;
  *)
    echo "Unknown host: ${HOST}" >&2
    usage >&2
    exit 1
    ;;
esac
