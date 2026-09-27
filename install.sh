#!/usr/bin/env bash
# Install these wallpapers into your wallpaper folder.
#
#   ./install.sh              copy into ~/Pictures/Wallpapers
#   ./install.sh --dir PATH   copy somewhere else
#   ./install.sh --list       just show what is available
#   ./install.sh --force      overwrite existing files without asking
#
# Only copies files that are missing or differ, so re-running is cheap and
# leaves wallpapers you have added yourself alone.

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/Wallpapers"
DEFAULT_DIR="$HOME/Pictures/Wallpapers"

dest="$DEFAULT_DIR"
force=false
list=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)   shift; dest="${1:?--dir needs a path}" ;;
    --force|-f) force=true ;;
    --list|-l) list=true ;;
    -h|--help)  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)  echo "unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

[[ -d $SRC ]] || { echo "error: $SRC not found" >&2; exit 1; }

count=0
for f in "$SRC"/*; do
  [[ -f $f ]] || continue
  n=$(basename "$f")
  if $list; then
    printf '  %-58s %6.1f MB\n' "$n" "$(du -m "$f" | cut -f1)"
    count=$((count + 1))
    continue
  fi
  count=$((count + 1))
done

$list && { echo; echo "$count wallpaper(s) in $SRC"; exit 0; }

echo "Source: $SRC"
echo "Target: $dest"
echo "Files:  $count"
echo

mkdir -p "$dest"
copied=0
skipped=0
for f in "$SRC"/*; do
  [[ -f $f ]] || continue
  n=$(basename "$f")
  if [[ -f "$dest/$n" ]] && cmp -s "$f" "$dest/$n"; then
    printf '  same     %s\n' "$n"
    skipped=$((skipped + 1))
    continue
  fi
  if [[ -e "$dest/$n" ]] && ! $force; then
    printf '  exists   %s  (use --force to overwrite)\n' "$n"
    skipped=$((skipped + 1))
    continue
  fi
  cp "$f" "$dest/$n"
  printf '  %-8s %s\n' "copied" "$n"
  copied=$((copied + 1))
done

echo
echo "Copied $copied, left $skipped alone."
echo "Wallpapers are in $dest"
if command -v swww >/dev/null; then
  echo "Set one with:  swww img set \"$dest/<file>\""
else
  echo "No swww found; pick one with your usual wallpaper tool."
fi
