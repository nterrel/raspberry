#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOT_DIR="$REPO_DIR/dotfiles"
BACKUP_DIR="$REPO_DIR/backup/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

link_one () {
  local src="$1"
  local dst="$2"

  if [ ! -e "$src" ]; then
    echo "SKIP: source missing: $src"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"

  # If dst exists and is already the correct symlink, do nothing
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    echo "OK: $dst already linked"
    return 0
  fi

  # If dst exists (file or symlink), back it up
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "BACKUP: $dst -> $BACKUP_DIR/"
    mv "$dst" "$BACKUP_DIR/"
  fi

  echo "LINK: $dst -> $src"
  ln -s "$src" "$dst"
}

# Repo dotfiles -> $HOME dotfiles
link_one "$DOT_DIR/.bashrc"        "$HOME/.bashrc"
link_one "$DOT_DIR/.bash_aliases"  "$HOME/.bash_aliases"
link_one "$DOT_DIR/.bash_logout"   "$HOME/.bash_logout"
link_one "$DOT_DIR/.profile"       "$HOME/.profile"
link_one "$DOT_DIR/.vimrc"         "$HOME/.vimrc"

# Keep only the last 10 backup directories
KEEP=10
ls -1dt "$REPO_DIR/backup/"* 2>/dev/null | tail -n +$((KEEP+1)) | xargs -r rm -rf

echo
echo "Done. Backups (if any) are in: $BACKUP_DIR"
echo "Open a new SSH session (or run 'source ~/.bashrc') to pick up changes."
