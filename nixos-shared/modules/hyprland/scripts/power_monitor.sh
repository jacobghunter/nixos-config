#!/usr/bin/env bash

# Paths injected from nix
STATIC_WALLPAPER="/nix/store/qi3biyjb3f8xw8rnjn03w8yqjik8cx9s-source/assets/backgrounds/outer-wilds.png"
WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"

# Track current state to prevent command spam
CURRENT_STATE="unknown"

start_or_resume_video() {
    if [ "$CURRENT_STATE" = "video" ]; then return; fi

    pkill -f awww-daemon 2>/dev/null

    if pgrep -f "linux-wallpaperengine" > /dev/null; then
        # Don't trust a partially-alive process — verify it's actually bound
        # to both outputs before resuming. If not, kill and relaunch clean.
        if ! pgrep -af "linux-wallpaperengine" | grep -q "DP-1" || \
           ! pgrep -af "linux-wallpaperengine" | grep -q "HDMI-A-1"; then
            pkill -f linux-wallpaperengine 2>/dev/null
            sleep 0.5
        else
            pkill -CONT -f linux-wallpaperengine
            CURRENT_STATE="video"
            return
        fi
    fi

    if [ -d "$WORKSHOP_DIR" ]; then
        linux-wallpaperengine --silent --fps 30 --scaling stretch \
            --screen-root DP-1 --bg "$WORKSHOP_DIR/2557395646" \
            --screen-root HDMI-A-1 --bg "$WORKSHOP_DIR/2984500160" > /dev/null 2>&1 &
    fi

    CURRENT_STATE="video"
}

start_static() {
    # If we are already in static mode, do absolutely nothing
    if [ "$CURRENT_STATE" = "static" ]; then return; fi

    # Pause the video engine (SIGSTOP) instead of killing it. 
    # This drops its CPU/GPU usage to 0% but keeps it in RAM for an instant wake-up.
    if pgrep -f "linux-wallpaperengine" > /dev/null; then
        pkill -STOP -f linux-wallpaperengine
    fi

    # Ensure awww is running and set the image over the paused engine
    if ! pgrep -f "awww-daemon" > /dev/null; then
        awww-daemon &
        sleep 0.5
    fi
    awww img "$STATIC_WALLPAPER" --transition-type none

    CURRENT_STATE="static"
}

check_power() {
    # Auto-recover if the wallpaper engine crashed in the background
    if [ "$CURRENT_STATE" = "video" ] && ! pgrep -f "linux-wallpaperengine" > /dev/null; then
        CURRENT_STATE="unknown"
    fi

    # Auto-recover if the static wallpaper daemon crashed in the background
    if [ "$CURRENT_STATE" = "static" ] && ! pgrep -f "awww-daemon" > /dev/null; then
        CURRENT_STATE="unknown"
    fi

    AC_SUPPLY=$(ls /sys/class/power_supply/ 2>/dev/null | grep -E "^(AC|ADP)" | head -n 1)

    if [ -z "$AC_SUPPLY" ]; then
        start_or_resume_video
        return
    fi

    STATUS=$(cat /sys/class/power_supply/$AC_SUPPLY/online 2>/dev/null)

    if [ "$STATUS" = "1" ]; then
        start_or_resume_video
    else
        start_static
    fi
}

# Main event loop: poll every 3 seconds to check power state and auto-recover crashes
while true; do
    check_power
    sleep 3
done