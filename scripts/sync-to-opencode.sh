#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.agent"

# Files to sync (repo-relative path → target basename)
FILES=(
  "CLAUDE.md"
  "AGENTS.md"
)

# Directories to sync (repo-relative path → target path, linked as directory)
DIRS=(
  "skills"
)

# ---------- helpers ----------

symlink_file() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    local current
    current=$(readlink "$dst")
    if [ "$current" = "$src" ]; then
      echo "  [OK] $dst"
      return
    fi
    echo "  [RM-link] $dst (was $current)"
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    echo "  [BACKUP] $dst → $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  echo "  [LINK] $dst → $src"
}

# ---------- main ----------

echo "==> Syncing haohui-de-skills → $TARGET"
echo "    Repo: $REPO_ROOT"
echo

mkdir -p "$TARGET"

for f in "${FILES[@]}"; do
  symlink_file "$REPO_ROOT/$f" "$TARGET/$f"
done

for d in "${DIRS[@]}"; do
  symlink_file "$REPO_ROOT/$d" "$TARGET/$d"
done

echo
echo "==> Done."
