pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../services"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.borderRadius
    height: 30

    // Only show if there is an active window
    visible: Hyprland.activeToplevel !== null
    opacity: visible ? 1.0 : 0.0
    
    // Smooth transition for visibility
    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }
    
    // Handle preferred width dynamically based on content but cap it
    Layout.preferredHeight: 30
    Layout.preferredWidth: visible ? Math.min(contentLayout.implicitWidth + 16, 250) : 0

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    // Helper mapping window class to Nerd Font icon
    function getAppIcon(appClass) {
        if (!appClass) return "";
        var cls = appClass.toLowerCase();
        if (cls.includes("kitty") || cls.includes("terminal") || cls.includes("foot") || cls.includes("alacritty")) {
            return "";
        }
        if (cls.includes("firefox") || cls.includes("chrome") || cls.includes("chromium") || cls.includes("brave") || cls.includes("librewolf")) {
            return "󰈹";
        }
        if (cls.includes("spotify") || cls.includes("music")) {
            return "󰓇";
        }
        if (cls.includes("discord") || cls.includes("vesktop") || cls.includes("webcord")) {
            return "󰙯";
        }
        if (cls.includes("steam")) {
            return "󰓓";
        }
        if (cls.includes("code") || cls.includes("vscodium") || cls.includes("neovim") || cls.includes("nvim")) {
            return "󰨞";
        }
        if (cls.includes("thunar") || cls.includes("nemo") || cls.includes("dolphin") || cls.includes("pcmanfm")) {
            return "󰉋";
        }
        if (cls.includes("obsidian")) {
            return "󰠮";
        }
        if (cls.includes("gimp") || cls.includes("inkscape") || cls.includes("krita")) {
            return "󰏘";
        }
        if (cls.includes("vlc") || cls.includes("mpv")) {
            return "󰕼";
        }
        return "";
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        // Application Icon
        Text {
            Layout.alignment: Qt.AlignVCenter
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 12
            color: Theme.secondary
            text: Hyprland.activeToplevel ? root.getAppIcon(Hyprland.activeToplevel.class) : ""
        }

        // Active Window Title
        Text {
            id: titleText
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 11
            color: Theme.primary
            text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
            elide: Text.ElideRight
        }
    }
}
