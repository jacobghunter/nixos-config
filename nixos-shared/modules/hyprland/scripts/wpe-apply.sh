#!/usr/bin/env bash
id="$1"
monitor_num="$2"
if [ -z "$id" ]; then
    echo "Usage: wpe-apply <workshop-id> [monitor-number (1, 2, ...)]"
    exit 1
fi
WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"
if [ ! -d "$WORKSHOP_DIR/$id" ]; then
    echo "Wallpaper ID $id not found in $WORKSHOP_DIR."
    exit 1
fi

# Kill awww-daemon to prevent static wallpaper conflicts
killall awww-daemon 2>/dev/null

if [ -n "$monitor_num" ]; then
    # Map monitor index (1-based) to monitor name sorted by ID
    monitor_name=$(hyprctl monitors -j | jq -r --argjson idx "$((monitor_num - 1))" 'sort_by(.id) | .[$idx] | .name' 2>/dev/null)
    if [ -z "$monitor_name" ] || [ "$monitor_name" = "null" ]; then
        echo "Monitor number $monitor_num not found."
        exit 1
    fi

    echo "Applying wallpaper $id to monitor $monitor_name (Monitor $monitor_num)..."
    pkill -f "linux-wallpaperengine --screen-root $monitor_name" 2>/dev/null
    sleep 0.2
    linux-wallpaperengine --screen-root "$monitor_name" --scaling stretch "$WORKSHOP_DIR/$id" > /dev/null 2>&1 &
else
    echo "Applying wallpaper $id to all monitors..."
    killall linux-wallpaperengine 2>/dev/null
    sleep 0.3
    for monitor in $(hyprctl monitors -j | jq -r '.[] | .name'); do
        linux-wallpaperengine --screen-root "$monitor" --scaling stretch "$WORKSHOP_DIR/$id" > /dev/null 2>&1 &
    done
fi
