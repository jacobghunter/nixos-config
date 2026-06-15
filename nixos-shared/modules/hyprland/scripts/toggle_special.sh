#!/usr/bin/env bash
# Get current window info
WINDOW_INFO=$(hyprctl activewindow -j)
WORKSPACE=$(echo "$WINDOW_INFO" | jq -r '.workspace.name')

if [ "$WORKSPACE" == "special:magic" ]; then
    # Move OUT to the active workspace of the current monitor
    MONITOR_ID=$(echo "$WINDOW_INFO" | jq -r '.monitor')
    TARGET=$(hyprctl monitors -j | jq -r --argjson m "$MONITOR_ID" '.[] | select(.id == $m) | .activeWorkspace.name')
    hyprctl dispatch movetoworkspace "name:$TARGET"
else
    # Move IN to special workspace
    hyprctl dispatch movetoworkspace "special:magic"
fi
