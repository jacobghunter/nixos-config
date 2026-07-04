#!/usr/bin/env bash
WORKSHOP_DIR="$HOME/.steam/steam/steamapps/workshop/content/431960"
if [ ! -d "$WORKSHOP_DIR" ]; then
    echo "Wallpaper Engine workshop directory not found."
    exit 1
fi

echo "Available Wallpaper Engine Wallpapers:"
echo "--------------------------------------"
for dir in "$WORKSHOP_DIR"/*; do
    if [ -d "$dir" ] && [ -f "$dir/project.json" ]; then
        id=$(basename "$dir")
        title=$(jq -r '.title' "$dir/project.json" 2>/dev/null)
        echo -e "\033[1;32m[$id]\033[0m - $title"
    fi
done
