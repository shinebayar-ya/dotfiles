#!/usr/bin/env bash
input=$(cat)
H="$HOME/.claude"

# One jq call; unit-separator keeps empty fields from collapsing
IFS=$'\x1f' read -r model cwd used total pct h5 h5r d7 d7r < <(echo "$input" | jq -r '[
  .model.display_name // "",
  .workspace.current_dir // "",
  .context_window.total_input_tokens // 0,
  .context_window.context_window_size // 0,
  .context_window.used_percentage // "",
  .rate_limits.five_hour.used_percentage // "",
  .rate_limits.five_hour.resets_at // "",
  .rate_limits.seven_day.used_percentage // "",
  .rate_limits.seven_day.resets_at // ""
] | map(tostring) | join("\u001f")')

R=$'\033[0m'; DIM=$'\033[2m'

# green <50, yellow <80, red
col() { if (( $1 >= ${3:-80} )); then printf '\033[31m'; elif (( $1 >= ${2:-50} )); then printf '\033[33m'; else printf '\033[32m'; fi; }

# "2h13m" / "3d4h" until epoch $1
left() {
  local s=$(( $1 - $(date +%s) ))
  (( s <= 0 )) && { printf 'now'; return; }
  if (( s >= 86400 )); then printf '%dd%dh' $((s/86400)) $((s%86400/3600))
  elif (( s >= 3600 )); then printf '%dh%02dm' $((s/3600)) $((s%3600/60))
  else printf '%dm' $((s/60)); fi
}

# "label 42% 2h13m"
limit() {
  [[ -z "$2" ]] && return
  local p; p=$(printf '%.0f' "$2")
  printf '%s%s %d%%%s' "$(col "$p")" "$1" "$p" "$R"
  [[ -n "$3" ]] && printf '%s %s%s' "$DIM" "$(left "${3%.*}")" "$R"
}

branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
dirty=""; [[ -n "$branch" && -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ]] && dirty="*"

parts=()
parts+=("$model")
parts+=("$(basename "$cwd")${branch:+ $branch$dirty}")

# Mode flags
caveman=$(echo "$input" | bash "$H/hooks/caveman-statusline.sh" 2>/dev/null)
[[ -n "$caveman" ]] && parts+=("$caveman")
[[ -f "$H/.unslop-active" ]] && parts+=($'\033[35m[UNSLOP]\033[0m')
pony=$(head -c 16 "$H/.ponytail-active" 2>/dev/null | tr -cd 'a-z')
[[ -n "$pony" ]] && parts+=($'\033[36m'"[PONYTAIL:${pony^^}]"$'\033[0m')

ctxmode=$(echo "$input" | context-mode statusline 2>/dev/null)
[[ -n "$ctxmode" ]] && parts+=("$ctxmode")

# Context
if [[ -n "$pct" && "$total" -gt 0 ]]; then
  p=$(printf '%.0f' "$pct")
  parts+=("$(col "$p" 30 60)ctx $((used/1000))k/$((total/1000))k $p%$R")
fi

# Session limits
l5=$(limit 5h "$h5" "$h5r"); [[ -n "$l5" ]] && parts+=("$l5")
l7=$(limit wk "$d7" "$d7r"); [[ -n "$l7" ]] && parts+=("$l7")

out=""; for p in "${parts[@]}"; do out+="${out:+ ${DIM}|${R} }$p"; done
printf '%s\n' "$out"
