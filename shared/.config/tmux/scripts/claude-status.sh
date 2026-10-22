#!/bin/sh
# Claude Code hook helper: record agent state (and a status-bar icon) on the tmux window.
[ -n "$TMUX_PANE" ] || exit 0
case "$1" in
  working) icon="#[fg=yellow]󰔟" ;;
  waiting) icon="#[fg=red,bold]󰂞" ;;
  idle)    icon="#[fg=brightblack]󰄬" ;;
  clear)
    tmux set-option -wu -t "$TMUX_PANE" @claude_status
    tmux set-option -wu -t "$TMUX_PANE" @claude_icon
    exit 0 ;;
esac
tmux set-option -w -t "$TMUX_PANE" @claude_status "$1"
tmux set-option -w -t "$TMUX_PANE" @claude_icon "$icon"
