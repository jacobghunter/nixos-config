#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-toggle}"

# Get active workspace info
ACTIVE_WORKSPACE=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.name')
MONITOR_ID=$(hyprctl activeworkspace -j | jq -r '.monitorID')

move_to_special() {
    if [[ "$ACTIVE_WORKSPACE" == special:* ]]; then
        return
    fi
    # Sort windows spatially by Y-coordinate, then X-coordinate
    WINDOW_ADDRESSES=$(hyprctl clients -j | jq -r --arg ws "$ACTIVE_WORKSPACE" '[.[] | select(.workspace.name == $ws)] | sort_by([.at[1], .at[0]]) | .[].address')
    for addr in $WINDOW_ADDRESSES; do
        hyprctl dispatch movetoworkspacesilent "special:magic,address:$addr"
    done
    # Open the special workspace to follow the windows
    hyprctl dispatch togglespecialworkspace magic
}

move_from_special() {
    local was_in_special=false
    if [[ "$ACTIVE_WORKSPACE" == special:* ]]; then
        was_in_special=true
        TARGET_WORKSPACE=$(hyprctl monitors -j | jq -r --argjson m "$MONITOR_ID" '.[] | select(.id == $m) | .activeWorkspace.name')
    else
        TARGET_WORKSPACE="$ACTIVE_WORKSPACE"
    fi
    # Sort windows spatially by Y-coordinate, then X-coordinate
    WINDOW_ADDRESSES=$(hyprctl clients -j | jq -r '[.[] | select(.workspace.name == "special:magic")] | sort_by([.at[1], .at[0]]) | .[].address')
    for addr in $WINDOW_ADDRESSES; do
        hyprctl dispatch movetoworkspacesilent "$TARGET_WORKSPACE,address:$addr"
    done
    # If we were inside the special workspace, close it to return to the normal workspace
    if [ "$was_in_special" = true ]; then
        hyprctl dispatch togglespecialworkspace magic
    fi
}

if [ "$ACTION" = "to" ]; then
    move_to_special
elif [ "$ACTION" = "from" ]; then
    move_from_special
else
    if [[ "$ACTIVE_WORKSPACE" == special:magic ]]; then
        move_from_special
    else
        WINDOW_COUNT=$(hyprctl clients -j | jq -r --arg ws "$ACTIVE_WORKSPACE" '[.[] | select(.workspace.name == $ws)] | length')
        if [ "$WINDOW_COUNT" -gt 0 ]; then
            move_to_special
        else
            move_from_special
        fi
    fi
fi
