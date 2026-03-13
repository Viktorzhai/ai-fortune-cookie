#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install AI Fortune Cookie into the local Codex skills directory.

Usage:
  ./install.sh [--copy] [--force]

Options:
  --copy   Copy runtime files instead of creating a symlink
  --force  Replace an existing install
  -h, --help
EOF
}

MODE="symlink"
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy)
      MODE="copy"
      ;;
    --force)
      FORCE=1
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
DEST_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
DEST_DIR="${DEST_ROOT}/ai-fortune-cookie"

mkdir -p "${DEST_ROOT}"

if [[ -e "${DEST_DIR}" || -L "${DEST_DIR}" ]]; then
  if [[ "${FORCE}" -ne 1 ]]; then
    echo "Install target already exists: ${DEST_DIR}" >&2
    echo "Re-run with --force to replace it." >&2
    exit 1
  fi
  rm -rf "${DEST_DIR}"
fi

if [[ "${MODE}" == "copy" ]]; then
  mkdir -p "${DEST_DIR}"
  cp "${REPO_DIR}/SKILL.md" "${DEST_DIR}/"

  for item in agents scripts references assets; do
    if [[ -e "${REPO_DIR}/${item}" ]]; then
      cp -R "${REPO_DIR}/${item}" "${DEST_DIR}/"
    fi
  done
else
  ln -s "${REPO_DIR}" "${DEST_DIR}"
fi

echo "Installed AI Fortune Cookie to ${DEST_DIR}"
