#!/bin/bash
# Claude Code status line
# Mirrors the zsh PROMPT/RPROMPT defined in ~/.zshrc:
#   PROMPT=$'%{\e[31m%}%n@%M %{\e[33m%}%* %# %{\e[m%}'
#   RPROMPT="%1(v|%F{green}%1v%f|)"  (vcs_info: "(%s)-[%b]")
#
# Layout: <red>user@host</red> <yellow>HH:MM:SS</yellow> <green>(git)-[branch]</green>

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
RESET=$'\033[0m'

user=$(whoami)
host=$(hostname -s)
time_str=$(date +%H:%M:%S)

git_info=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi

  action=""
  git_dir=$(git -C "$cwd" --no-optional-locks rev-parse --git-dir 2>/dev/null)
  if [ -n "$git_dir" ]; then
    if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
      action="rebase"
    elif [ -f "$git_dir/MERGE_HEAD" ]; then
      action="merge"
    elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
      action="cherry-pick"
    fi
  fi

  if [ -n "$branch" ]; then
    if [ -n "$action" ]; then
      git_info="(git)-[${branch}|${action}]"
    else
      git_info="(git)-[${branch}]"
    fi
  fi
fi

printf '%s%s@%s%s %s%s%s' "$RED" "$user" "$host" "$RESET" "$YELLOW" "$time_str" "$RESET"
if [ -n "$git_info" ]; then
  printf ' %s%s%s' "$GREEN" "$git_info" "$RESET"
fi
printf '\n'
