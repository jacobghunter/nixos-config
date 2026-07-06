import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../modules"

// FIX: Make the root element the actual visual Rectangle
Rectangle {
    id: barRoot

    // Caelestia-style transparent crust
    color: Theme.crust
    border.color: Theme.borderColor
    border.width: Theme.borderSize
    radius: Theme.borderRadius

    ClockEngine {
        id: clockService
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        // Workspace Switcher (Left)
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6
            Repeater {
                model: Hyprland.workspaces
                Rectangle {
                    id: wsRect
                    required property var modelData
                    width: 26
                    height: 26
                    radius: 6
                    color: wsRect.modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0) ? "#b4befe" : "#1e1e2e"

                    Text {
                        anchors.centerIn: parent
                        text: wsRect.modelData.id
                        color: wsRect.modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0) ? "#11111b" : "#bac2de"
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // Active Title (Center)
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Desktop"
            color: "#cdd6f4"
        }

        Item {
            Layout.fillWidth: true
        }

        // Live Clock Component (Right)
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: clockService.timeString
            color: "#b4befe"
            font.bold: true
        }
    }
}
