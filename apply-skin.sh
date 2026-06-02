#!/bin/bash
# apply-skin.sh — Copy skins from this repo to ~/.hermes/skins/
# Usage: ./apply-skin.sh [skin-name]  (default: all skins in skins/)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKINS_DIR="${REPO_DIR}/skins"
DEST_DIR="${HOME}/.hermes/skins"

mkdir -p "$DEST_DIR"

apply_one() {
  local name="$1"
  local src="${SKINS_DIR}/${name}.yaml"

  if [ ! -f "$src" ]; then
    echo "ERROR: ${src} not found" >&2
    return 1
  fi

  # Validate: file must contain a "name:" key
  if ! grep -qE '^\s*name\s*:' "$src"; then
    echo "ERROR: invalid skin — missing name key in ${src}" >&2
    return 1
  fi
  echo "Validated: ${name}"

  cp -v "$src" "${DEST_DIR}/${name}.yaml"
  echo "Applied: ${name} → ${DEST_DIR}/${name}.yaml"
}

if [ $# -ge 1 ]; then
  apply_one "$1"
else
  count=0
  for src in "${SKINS_DIR}"/*.yaml; do
    [ -f "$src" ] || continue
    name="$(basename "$src" .yaml)"
    apply_one "$name" || exit 1
    ((count++))
  done
  echo "Applied ${count} skin(s) → ${DEST_DIR}/"
fi

echo ""
echo "To activate:"
echo "  hermes config set display.skin <name>"
echo "  /reset   (or restart Hermes)"
