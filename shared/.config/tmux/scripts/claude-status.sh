#!/bin/sh
# Claude Code hook helper: record agent state on the tmux window.
[ -n "$TMUX_PANE" ] || exit 0
if [ "$1" = clear ]; then
  tmux set-option -wu -t "$TMUX_PANE" @claude_status
else
  tmux set-option -w -t "$TMUX_PANE" @claude_status "$1"
fi
