#!/bin/bash
# Claude Code status line (2 lines)
#
# Line 1: [model] context% | cost
# Line 2: 5h limit (reset) | 7d limit (reset) | git branch | dir

input=$(cat)

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
RESET=$'\033[0m'

ICON_BRAIN="🧠"
ICON_MONEY="💰"
ICON_5H="⏱️"
ICON_7D="📅"
ICON_GIT="🐙"
ICON_DIR="📁"

# --- helpers -----------------------------------------------------------

# ISO8601 (assumed UTC, "...Z" or with fractional seconds) -> epoch seconds
iso_to_epoch() {
  local ts="$1"
  [ -z "$ts" ] && return 1
  local clean
  clean=$(printf '%s' "$ts" | sed -E 's/\.[0-9]+Z?$/Z/; s/Z$//')
  local epoch
  epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null)
  if [ -z "$epoch" ]; then
    epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null)
  fi
  [ -z "$epoch" ] && return 1
  printf '%s' "$epoch"
}

# epoch -> local "HH:MM"
local_hm() {
  date -r "$1" "+%H:%M" 2>/dev/null
}

# epoch -> local "M/D HH:MM" (no leading zeros on month/day)
local_mdhm() {
  local epoch="$1" m d hm
  m=$(date -r "$epoch" "+%m" 2>/dev/null)
  d=$(date -r "$epoch" "+%d" 2>/dev/null)
  hm=$(date -r "$epoch" "+%H:%M" 2>/dev/null)
  [ -z "$hm" ] && return 1
  printf '%s/%s %s' "${m#0}" "${d#0}" "$hm"
}

# --- parse status line JSON --------------------------------------------

model_name=$(jq -r '.model.display_name // "unknown"' <<<"$input")
context_pct=$(jq -r '((.context_window.used_percentage // 0) | round)' <<<"$input")
cost_usd=$(jq -r '(.cost.total_cost_usd // 0)' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // .cwd // "."' <<<"$input")

has_rate_limits=$(jq -r 'if .rate_limits then "1" else "0" end' <<<"$input")
has_five=$(jq -r 'if .rate_limits.five_hour then "1" else "0" end' <<<"$input")
has_seven=$(jq -r 'if .rate_limits.seven_day then "1" else "0" end' <<<"$input")
five_pct=$(jq -r '((.rate_limits.five_hour.used_percentage // 0) | round)' <<<"$input")
five_resets_at=$(jq -r '.rate_limits.five_hour.resets_at // ""' <<<"$input")
seven_pct=$(jq -r '((.rate_limits.seven_day.used_percentage // 0) | round)' <<<"$input")
seven_resets_at=$(jq -r '.rate_limits.seven_day.resets_at // ""' <<<"$input")

cost_fmt=$(printf '%.2f' "$cost_usd")

# --- line 1: session info ----------------------------------------------

context_color="$GREEN"
if [ "$context_pct" -ge 80 ]; then
  context_color="$RED"
elif [ "$context_pct" -ge 50 ]; then
  context_color="$YELLOW"
fi

line1="[${model_name}] ${ICON_BRAIN} ${context_color}${context_pct}%${RESET} | ${ICON_MONEY} \$${cost_fmt}"

# --- line 2: rate limits + git + dir -----------------------------------

segments=()

if [ "$has_rate_limits" = "1" ] && [ "$has_five" = "1" ]; then
  if [ "$five_pct" -ge 80 ]; then
    five_str="${ICON_5H} 5h: ${RED}${five_pct}%${RESET}"
  else
    five_str="${ICON_5H} 5h: ${five_pct}%"
  fi
  five_epoch=$(iso_to_epoch "$five_resets_at")
  if [ -n "$five_epoch" ]; then
    five_hm=$(local_hm "$five_epoch")
    [ -n "$five_hm" ] && five_str="${five_str} (reset ${five_hm})"
  fi
  segments+=("$five_str")
fi

if [ "$has_rate_limits" = "1" ] && [ "$has_seven" = "1" ]; then
  seven_str="${ICON_7D} 7d: ${seven_pct}%"
  seven_epoch=$(iso_to_epoch "$seven_resets_at")
  if [ -n "$seven_epoch" ]; then
    seven_mdhm=$(local_mdhm "$seven_epoch")
    [ -n "$seven_mdhm" ] && seven_str="${seven_str} (${seven_mdhm})"
  fi
  segments+=("$seven_str")
fi

if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      dirty="*"
    fi
    segments+=("${ICON_GIT} ${branch}${dirty}")
  fi
fi

dir_name=$(basename "$cwd")
segments+=("${ICON_DIR} ${dir_name}")

line2=""
for seg in "${segments[@]}"; do
  if [ -z "$line2" ]; then
    line2="$seg"
  else
    line2="${line2} | ${seg}"
  fi
done

printf '%s\n%s\n' "$line1" "$line2"
