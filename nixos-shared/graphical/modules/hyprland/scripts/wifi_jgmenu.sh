#!/usr/bin/env bash

# Generate menu content
{
    echo "<b>Wi-Fi Networks</b>,^sep()"
    
    # Use cached results (remove --rescan yes) for instant rendering
    nmcli -t -f SSID,SECURITY,BARS,ACTIVE device wifi list | awk -F: '!seen[$1]++' | while IFS=: read -r ssid security bars active; do
        if [[ -z "$ssid" ]]; then continue; fi
        
        display_text="$ssid"
        if [[ "$active" == "yes" ]]; then
            display_text="<b>* $ssid</b>"
        fi
        
        # Escape quotes in SSID for the command
        safe_ssid=$(echo "$ssid" | sed 's/"/\\"/g')
        
        # jgmenu format: Label, command
        echo "$display_text  <small>($bars)</small>,nmcli device wifi connect \"$safe_ssid\" && notify-send \"Connected to $safe_ssid\""
    done

    echo "^sep()"
    echo "  Rescan Networks,notify-send 'Scanning...' && nmcli device wifi list --rescan yes && notify-send 'Scan Complete' 'Re-open menu to see new networks'"
    echo "Open Connection Editor,nm-connection-editor"
} | jgmenu --simple --at-pointer
