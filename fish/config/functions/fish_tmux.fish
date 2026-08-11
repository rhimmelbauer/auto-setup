function fish_tmux
end

function t-ls
    tmux ls
end

function t-kill
    tmux kill-session -t $argv[1]
end

function t-new
    tmux new -s $argv[1]
end

function t-attach
    tmux attach -t $argv[1]
end

function tmux-start
  if not tmux has-session -t $argv[1] 2>/dev/null
    echo "Creating new tmux session " $argv[1]
    tmux new -d -s $argv[1]
  else
    echo "Tmux session started"
  end

  tmux a -t $argv[1]
end

function tmux-config
  if not tmux has-session -t "config" 2>/dev/null
    tmux new -d -s config
    tmux send-keys -t config "cd ~/.config" C-m
    tmux send-keys -t config "nvim ." C-m
  end

  tmux a -t config
end
