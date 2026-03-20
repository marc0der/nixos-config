#!/usr/bin/env bash
# Claude Code status line - mirrors Powerlevel10k classic style
# Segments: dir | git branch | model | context usage | user@host | time

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Shorten home directory to ~
home_dir="$HOME"
short_cwd="${cwd/#$home_dir/~}"

# Git branch (skip locking to avoid conflicts)
git_branch=""
if git_out=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null); then
  git_branch=" $git_out"
fi

# Context usage indicator
ctx_info=""
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  if [ "$used_int" -ge 75 ]; then
    ctx_info=" ctx:${used_pct}%"
  else
    remaining_int=${remaining_pct%.*}
    ctx_info=" ctx:${remaining_pct}% left"
  fi
fi

# Time
time_str=$(date +%H:%M:%S)

# user@host
user_host="$(whoami)@$(hostname -s)"

printf "\033[34m%s\033[0m\033[33m%s\033[0m \033[90m|\033[0m \033[32m%s\033[0m \033[90m|\033[0m%s \033[90m|\033[0m \033[36m%s\033[0m \033[90m|\033[0m \033[35m%s\033[0m" \
  "$short_cwd" \
  "$git_branch" \
  "$model" \
  "$ctx_info" \
  "$user_host" \
  "$time_str"
