#!/usr/bin/env bash
set -euo pipefail

# Get info for the currently focused monitor
MONITOR_JSON=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
WORKSPACE=$(echo "$MONITOR_JSON" | jq -r 'if .specialWorkspace.name != "" then .specialWorkspace.name else .activeWorkspace.name end')

if [[ "$WORKSPACE" == "special:magic" ]]; then
    # We are in special, move OUT
    TARGET=$(echo "$MONITOR_JSON" | jq -r '.activeWorkspace.name')
    hyprctl dispatch "hl.dsp.window.move({ workspace = 'name:$TARGET', follow = true })"
else
    # We are in normal, move IN
    hyprctl dispatch 'hl.dsp.window.move({ workspace = "special:magic", follow = true })'
fi