#!/usr/bin/env bash

# Unique substrings matching your audio sinks in 'wpctl status'
DEV1_NAME="LSX II LT"
DEV2_NAME="Qudelix-5K"

# Find current dynamic IDs for each device
ID1=$(wpctl status | grep -A 10 "Sinks:" | grep "$DEV1_NAME" | grep -oP '\d+(?=\.)' | head -n 1)
ID2=$(wpctl status | grep -A 10 "Sinks:" | grep "$DEV2_NAME" | grep -oP '\d+(?=\.)' | head -n 1)

# Exit if either device is not connected/found
if [ -z "$ID1" ] || [ -z "$ID2" ]; then
    notify-send "Audio Error" "Could not find LSX II LT or Qudelix-5K." --transient
    exit 1
fi

# Toggle logic: if LSX II LT is default, switch to Qudelix-5K; otherwise, switch to LSX II LT
if wpctl status | grep -A 10 "Sinks:" | grep "$DEV1_NAME" | grep -q '\*'; then
    wpctl set-default "$ID2"
    notify-send "Audio Output" "Switched to Qudelix-5K (Headphones)" --icon=audio-headphones --transient
else
    wpctl set-default "$ID1"
    notify-send "Audio Output" "Switched to LSX II LT (Speakers)" --icon=audio-speakers --transient
fi
