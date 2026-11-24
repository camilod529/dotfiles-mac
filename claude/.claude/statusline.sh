#!/usr/bin/env bash
# Claude Code status line: model | parent-dir | branch[*] | context bar
input=$(cat)

model=$(jq -r '.model.display_name // "?"' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // empty' <<<"$input")
pct=$(jq -r '.context_window.used_percentage // 0' <<<"$input")

# Abbreviate model: drop "Claude " prefix and any "(...)" suffix, e.g. "Claude Opus 5.5 (1M context)" -> "Opus 5.5"
model=$(sed -E 's/^Claude //; s/ *\(.*\)$//' <<<"$model")

# Parent folder of the cwd (distinguishes multiple clones of the same repo)
parent=$(basename "$(dirname "${cwd:-$PWD}")")

# Git branch, with * when the working tree is dirty
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | head -1)" ]; then
    branch="${branch}*"
  fi
fi

# 14-block context bar
pct_int=$(printf '%.0f' "$pct" 2>/dev/null || echo 0)
[ "$pct_int" -gt 100 ] && pct_int=100
[ "$pct_int" -lt 0 ] && pct_int=0
filled=$(( (pct_int * 14 + 50) / 100 ))
bar=""
for ((i = 0; i < 14; i++)); do
  if [ "$i" -lt "$filled" ]; then bar+="█"; else bar+="░"; fi
done

out="$model | $parent"
[ -n "$branch" ] && out+=" | $branch"
out+=" | $bar ${pct_int}%"
printf '%s' "$out"
