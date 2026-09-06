#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-toggle}"

# Get active workspace info
ACTIVE_WORKSPACE=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | if .specialWorkspace.name != "" then .specialWorkspace.name else .activeWorkspace.name end')

move_to_special() {
    if [[ "$ACTIVE_WORKSPACE" == special:* ]]; then
        return
    fi
    # Sort windows spatially by Y-coordinate, then X-coordinate (reversed to preserve layout when moving silently)
    WINDOW_ADDRESSES=$(hyprctl clients -j | jq -r --arg ws "$ACTIVE_WORKSPACE" '[.[] | select(.workspace.name == $ws)] | sort_by([.at[1], .at[0]]) | reverse | .[].address')
    for addr in $WINDOW_ADDRESSES; do
        hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:magic', follow = false, window = 'address:$addr' })"
    done
    # Open the special workspace to follow the windows
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("magic")'
}

move_from_special() {
    local was_in_special=false
    if [[ "$ACTIVE_WORKSPACE" == special:* ]]; then
        was_in_special=true
        TARGET_WORKSPACE=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.name')
    else
        TARGET_WORKSPACE="$ACTIVE_WORKSPACE"
    fi
    # Sort windows spatially by Y-coordinate, then X-coordinate (reversed to preserve layout when moving silently)
    WINDOW_ADDRESSES=$(hyprctl clients -j | jq -r '[.[] | select(.workspace.name == "special:magic")] | sort_by([.at[1], .at[0]]) | reverse | .[].address')
    for addr in $WINDOW_ADDRESSES; do
        hyprctl dispatch "hl.dsp.window.move({ workspace = '$TARGET_WORKSPACE', follow = false, window = 'address:$addr' })"
    done
    # If we were inside the special workspace, close it to return to the normal workspace
    if [ "$was_in_special" = true ]; then
        hyprctl dispatch 'hl.dsp.workspace.toggle_special("magic")'
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
