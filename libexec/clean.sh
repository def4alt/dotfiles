#!/usr/bin/env bash
# Retention for state that only grows: agent transcripts, session jobs, scratch
# directories and old backups. Dry-run by default; pass --apply to delete.
set -euo pipefail

apply=0
[ "${1:-}" = "--apply" ] && apply=1

# dir:days — entries directly inside the directory older than N days
targets=(
  "$HOME/.claude/jobs:30"
  "$HOME/.claude/projects:90"
  "$HOME/.codex/archived_sessions:90"
  "$HOME/.codex/sessions:90"
  "$HOME/.pi/agent/sessions:90"
  "$HOME/.local/share/opencode/worktree:30"
  "$HOME/src/scratch:14"
  "$HOME/backups:90"
)

human() {
  awk -v k="$1" 'BEGIN {
    if (k >= 1048576) printf "%.1fG", k / 1048576
    else if (k >= 1024) printf "%.0fM", k / 1024
    else printf "%dK", k
  }'
}

total=0
for target in "${targets[@]}"; do
  dir=${target%:*}
  days=${target##*:}
  [ -d "$dir" ] || continue

  stale=$(find "$dir" -mindepth 1 -maxdepth 1 -mtime "+$days" 2>/dev/null || true)
  [ -n "$stale" ] || continue

  # `du -sk` needs real paths; count symlinks and dirs alike.
  size=$(printf '%s\n' "$stale" | while IFS= read -r entry; do du -sk -- "$entry" 2>/dev/null; done |
    awk '{s += $1} END {print s + 0}')
  count=$(printf '%s\n' "$stale" | wc -l | tr -d ' ')
  total=$((total + size))
  printf '  %-40s >%-3s days  %6s  %s entries\n' "${dir#"$HOME"/}" "$days" "$(human "$size")" "$count"

  if [ "$apply" = "1" ]; then
    while IFS= read -r entry; do
      rm -rf -- "$entry"
    done <<<"$stale"
  fi
done

echo
if [ "$total" -eq 0 ]; then
  echo "clean: nothing outside the retention windows"
elif [ "$apply" = "1" ]; then
  echo "clean: reclaimed $(human "$total")"
else
  echo "clean: $(human "$total") reclaimable — re-run with --apply"
fi
