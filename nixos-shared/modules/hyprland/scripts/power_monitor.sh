#!/usr/bin/env bash

# Paths injected from nix
STATIC_WALLPAPER="/nix/store/qi3biyjb3f8xw8rnjn03w8yqjik8cx9s-source/assets/backgrounds/outer-wilds.png"
WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"

# Track current state to prevent command spam
CURRENT_STATE="unknown"

start_or_resume_video() {
    # If we are already in video mode, do absolutely nothing
    if [ "$CURRENT_STATE" = "video" ]; then return; fi

    # Kill static wallpaper daemon if running
    killall awww-daemon 2>/dev/null

    # Check if engine is running but paused
    if pgrep "linux-wallpaperengine" > /dev/null; then
        # Resume it instantly (SIGCONT) - No cold boot, no black flash
        killall -CONT linux-wallpaperengine
    else
        # Start it for the very first time
        if [ -d "$WORKSHOP_DIR" ]; then
            linux-wallpaperengine --silent --fps 60 --scaling stretch \
                --screen-root DP-1 --bg "$WORKSHOP_DIR/2557395646" \
                --screen-root HDMI-A-1 --bg "$WORKSHOP_DIR/2984500160" > /dev/null 2>&1 &
        fi
    fi

    CURRENT_STATE="video"
}

start_static() {
    # If we are already in static mode, do absolutely nothing
    if [ "$CURRENT_STATE" = "static" ]; then return; fi

    # Pause the video engine (SIGSTOP) instead of killing it. 
    # This drops its CPU/GPU usage to 0% but keeps it in RAM for an instant wake-up.
    if pgrep "linux-wallpaperengine" > /dev/null; then
        killall -STOP linux-wallpaperengine
    fi

    # Ensure awww is running and set the image over the paused engine
    if ! pgrep "awww-daemon" > /dev/null; then
        awww-daemon &
        sleep 0.5
    fi
    awww img "$STATIC_WALLPAPER" --transition-type none

    CURRENT_STATE="static"
}

check_power() {
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

# Initial check
check_power

# Event loop
upower --monitor | while read -r line; do
    check_power
done

# If upower crashes and the loop breaks, exit 1 so systemd knows to restart the script
exit 1