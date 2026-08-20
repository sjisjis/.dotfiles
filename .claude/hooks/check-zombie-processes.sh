#!/bin/bash
# Claude Code ゾンビプロセスチェッカー
#
# 呼び出し方:
#   hook (SessionStart)      → 詳細メッセージ（kill コマンド付き）
#   --statusline [残り分数]   → 短縮表示（Reset<60min or 2時間おき）
#                              残り分数は statusline が rate_limits.five_hour.resets_at
#                              から算出した実値を渡す。省略時は2時間ゲートのみで判定

THRESHOLD_HOURS=3
STATUSLINE_MODE=false
[ "$1" = "--statusline" ] && STATUSLINE_MODE=true

# === statusline モード: 時間ゲート ===
if $STATUSLINE_MODE; then
  CHECK_FILE="/tmp/claude-zombie-last-check"
  NOW=$(date +%s)
  LAST=0
  [ -f "$CHECK_FILE" ] && LAST=$(cat "$CHECK_FILE" 2>/dev/null)
  SINCE=$(( NOW - LAST ))

  # Reset残り時間: 呼び出し元（statusline）から実値を受け取る
  # 5hウィンドウの起点は「そのウィンドウで最初に送ったメッセージの時刻」で毎回動くため、
  # 固定周期からの外挿はできない。渡されなければゲートを無効化（999）する
  RESET_MIN=999
  case "$2" in
    ''|*[!0-9]*) ;;
    *) RESET_MIN=$2 ;;
  esac

  # Reset<60min or 前回から2時間経過 でなければスキップ
  if [ "$RESET_MIN" -ge 60 ] && [ "$SINCE" -lt 7200 ]; then
    exit 0
  fi
  echo "$NOW" > "$CHECK_FILE"
fi

# === ゾンビ検出 ===
ZOMBIE_PIDS=()
while IFS= read -r line; do
  PID=$(echo "$line" | awk '{print $1}')
  ELAPSED=$(echo "$line" | awk '{print $2}')

  if echo "$ELAPSED" | grep -q '-'; then
    ZOMBIE_PIDS+=("$PID")
  elif echo "$ELAPSED" | grep -qE '^[0-9]{2,}:[0-9]{2}:[0-9]{2}$'; then
    HOURS=$(echo "$ELAPSED" | cut -d: -f1)
    [ "$HOURS" -ge "$THRESHOLD_HOURS" ] && ZOMBIE_PIDS+=("$PID")
  fi
done < <(ps -o pid=,etime= -p $(pgrep -d, claude 2>/dev/null) 2>/dev/null)

[ ${#ZOMBIE_PIDS[@]} -eq 0 ] && exit 0

# === 出力 ===
IDS=$(IFS=,; echo "${ZOMBIE_PIDS[*]}")

if $STATUSLINE_MODE; then
  echo "☠${#ZOMBIE_PIDS[@]}zombie:${IDS}"
else
  echo "⚠️ ${#ZOMBIE_PIDS[@]}個のClaudeゾンビプロセスが${THRESHOLD_HOURS}時間以上動いとるばい: ${IDS}"
  echo "   kill するなら: kill -9 ${ZOMBIE_PIDS[*]}"
fi