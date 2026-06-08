#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh TARGET_DIR [CONTEXT_FILENAME]

Links the portable skills directory and AGENTS.md into an agent config directory.
CONTEXT_FILENAME defaults to AGENTS.md.
EOF
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  usage >&2
  exit 2
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
target=$1
context_name=${2:-AGENTS.md}

if [[ "$context_name" == */* ]] || [ -z "$context_name" ]; then
  echo "CONTEXT_FILENAME must be a plain filename." >&2
  exit 2
fi

link_path() {
  local src=$1
  local dst=$2

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  [OK] $dst"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo "  [BACKUP] $dst -> $backup"
  fi

  ln -s "$src" "$dst"
  echo "  [LINK] $dst -> $src"
}

mkdir -p "$target"

echo "Installing portable agent resources"
echo "  Source: $repo_root"
echo "  Target: $target"

link_path "$repo_root/AGENTS.md" "$target/$context_name"
link_path "$repo_root/skills" "$target/skills"

echo "Done."
