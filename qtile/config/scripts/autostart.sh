#!/bin/bash

keymapper &
# xrandr --output DP-1-1 --rotate right;
# xrandr --output DP-1-1 --left-of eDP-1
# xrandr --output eDP-1 --pos 2160x2640
# blueman-applet &
flameshot &
caffeine-indicator &
# feh --randomize --big-fill /home/rhimmelbauer/Pictures/final/;
feh --randomize --bg-fill /home/rob/Pictures/Wallpaper\ Digest/;
# brave https://teams.microsoft.com/v2 https://outlook.office.com/mail/inbox/ &

tmux new -d -s config
tmux send-keys -t config "cd ~/.config" C-m
tmux send-keys -t config "nvim ." C-m
alacritty -T "config" -e tmux a -t config &
# ssh-add ~/.ssh/.....

