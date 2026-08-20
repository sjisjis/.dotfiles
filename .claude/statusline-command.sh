#!/bin/bash
# Claude Code status line (2 lines)
#
# Line 1: [model] context% | cost
# Line 2: 5h limit (reset + remaining + pace advice) | 7d limit | zombie | git branch | dir | elapsed

input=$(cat)
now_ts=$(date +%s)

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
BOLD_RED=$'\033[91;1m'
BOLD_GREEN=$'\033[92;1m'
BOLD_YELLOW=$'\033[93;1m'
RESET=$'\033[0m'

ICON_BRAIN="🧠"
ICON_MONEY="💰"
ICON_5H="⏱️"
ICON_7D="📅"
ICON_GIT="🐙"
ICON_DIR="📁"
ICON_TIME="⏳"

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

# resets_at はエポック秒(数値)とISO8601文字列の両方があり得るため両対応する
to_epoch() {
  local ts="$1"
  [ -z "$ts" ] && return 1
  ts="${ts%%.*}"
  case "$ts" in
    *[!0-9]*) iso_to_epoch "$1" ;;
    *) printf '%s' "$ts" ;;
  esac
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
session_id=$(jq -r '.session_id // ""' <<<"$input")

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

# --- line 2: rate limits + zombie + git + dir + elapsed -----------------

segments=()
remaining_min=""

if [ "$has_rate_limits" = "1" ] && [ "$has_five" = "1" ]; then
  if [ "$five_pct" -ge 80 ]; then
    five_str="${ICON_5H} 5h: ${RED}${five_pct}%${RESET}"
  else
    five_str="${ICON_5H} 5h: ${five_pct}%"
  fi

  five_epoch=$(to_epoch "$five_resets_at")
  pace_msg=""
  if [ -n "$five_epoch" ]; then
    five_hm=$(local_hm "$five_epoch")
    remaining=$(( five_epoch - now_ts ))
    if [ "$remaining" -gt 0 ]; then
      remaining_min=$(( remaining / 60 ))
      if [ "$remaining_min" -lt 60 ]; then
        remain_disp="残${remaining_min}m"
      else
        remain_disp="残$(( remaining_min / 60 ))h$(printf '%02d' $(( remaining_min % 60 )))m"
      fi
      [ -n "$five_hm" ] && five_str="${five_str} (reset ${five_hm}/${remain_disp})"

      # ペース配分アナウンス
      if [ "$remaining_min" -lt 60 ] && [ "$five_pct" -lt 50 ]; then
        pace_msg="${BOLD_GREEN}ガンガンいこうぜ！${RESET}"
      elif [ "$remaining_min" -lt 60 ] && [ "$five_pct" -ge 50 ]; then
        pace_msg="${BOLD_RED}いのちを大事に！${RESET}"
      elif { [ "$remaining_min" -ge 240 ] && [ "$five_pct" -ge 30 ]; } || \
           { [ "$remaining_min" -ge 180 ] && [ "$five_pct" -ge 50 ]; } || \
           { [ "$remaining_min" -ge 120 ] && [ "$five_pct" -ge 75 ]; } || \
           { [ "$remaining_min" -ge 60 ]  && [ "$five_pct" -ge 90 ]; }; then
        pace_msg="${BOLD_YELLOW}いのちを大事に！${RESET}"
      fi
    elif [ -n "$five_hm" ]; then
      five_str="${five_str} (reset ${five_hm})"
    fi
  fi
  [ -n "$pace_msg" ] && five_str="${five_str} ${pace_msg}"
  segments+=("$five_str")
fi

if [ "$has_rate_limits" = "1" ] && [ "$has_seven" = "1" ]; then
  seven_str="${ICON_7D} 7d: ${seven_pct}%"
  seven_epoch=$(to_epoch "$seven_resets_at")
  if [ -n "$seven_epoch" ]; then
    seven_mdhm=$(local_mdhm "$seven_epoch")
    [ -n "$seven_mdhm" ] && seven_str="${seven_str} (${seven_mdhm})"
  fi
  segments+=("$seven_str")
fi

# ゾンビプロセス警告(外部スクリプト。時間ゲートはスクリプト側で制御)
ZOMBIE_HOOK="$HOME/.claude/hooks/check-zombie-processes.sh"
if [ -f "$ZOMBIE_HOOK" ]; then
  zombie_result=$(bash "$ZOMBIE_HOOK" --statusline "${remaining_min:-}" 2>/dev/null)
  [ -n "$zombie_result" ] && segments+=("${RED}${zombie_result}${RESET}")
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

# セッション経過時間
if [ -n "$session_id" ]; then
  session_start_file="/tmp/claude-session-start-${session_id}"
  [ -f "$session_start_file" ] || printf '%s' "$now_ts" > "$session_start_file"
  start_ts=$(cat "$session_start_file" 2>/dev/null)
  if [ -n "$start_ts" ] 2>/dev/null; then
    diff=$(( now_ts - start_ts ))
    if [ "$diff" -ge 3600 ]; then
      elapsed="$(( diff / 3600 ))h$(printf '%02d' $(( (diff % 3600) / 60 )))m"
    else
      elapsed="$(( diff / 60 ))m"
    fi
    segments+=("${ICON_TIME} ${elapsed}")
  fi
fi

line2=""
for seg in "${segments[@]}"; do
  if [ -z "$line2" ]; then
    line2="$seg"
  else
    line2="${line2} | ${seg}"
  fi
done

printf '%s\n%s\n' "$line1" "$line2"
