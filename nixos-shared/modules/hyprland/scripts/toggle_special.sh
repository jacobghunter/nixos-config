#!/usr/bin/env bash
set -euo pipefail

# Get info for the currently focused monitor
MONITOR_JSON=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
WORKSPACE=$(echo "$MONITOR_JSON" | jq -r '.activeWorkspace.name')

if [[ "$WORKSPACE" == "special:magic" ]]; then
    # We are in special, move OUT
    hyprctl dispatch movetoworkspace "name:$WORKSPACE" # Hyprsplit handles the mapping
else
    # We are in normal, move IN
    hyprctl dispatch movetoworkspace "special:magic"
fi