#!/bin/zsh

# INFO: Start tmux only if not inside tmux already.
if [ -z "$TMUX" ]; then
  if tmux run 2>/dev/null; then
    if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
      #TMUX is not running
      FOUND_SESSION=false
      SESSION_ID=""
      SESSION_N=0
      #Find session to attach to
      for line in $(tmux ls -F "#{session_id}:#{?session_attached,attached,not-attached}"); do
        SESSION_ATTACHED=$(echo "$line" | cut -d':' -f2)
        if [ "$SESSION_ATTACHED" = "not-attached" ]; then
          SESSION_ID=$(echo "$line" | cut -d':' -f1)
          echo $SESSION_ID
          FOUND_SESSION=true
          break
        fi
        SESSION_N=$((SESSION_N+1))
      done

      if [ "$FOUND_SESSION" = true ]; then
        tmux attach-session -t "$SESSION_ID"
        exit
      else
        exec tmux new -s "$SESSION_N" -c "$PWD"
      fi
    fi
  else
    exec tmux new -s 0 -c "$PWD"
  fi

fi
