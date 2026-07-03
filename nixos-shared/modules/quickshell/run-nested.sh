#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Starting nested Hyprland session..."
# Run the host system's Hyprland directly in a sanitized environment
# (clearing LD_LIBRARY_PATH and Qt paths to prevent nix develop library pollution)
env -u LD_LIBRARY_PATH -u QT_PLUGIN_PATH -u QML2_IMPORT_PATH Hyprland -c ./nested.lua
