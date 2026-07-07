import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../modules"

// FIX: Make the root element the actual visual Rectangle
Rectangle {
    id: barRoot
    implicitHeight: mainLayout.implicitHeight

    // Caelestia-style transparent crust
    // color: Theme.crust
    color: "transparent"
    // border.color: Theme.borderColor
    // border.width: Theme.borderSize
    // radius: Theme.borderRadius

    ClockEngine {
        id: clockService
    }

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.leftMargin: Theme.borderRadius / 2
        anchors.rightMargin: Theme.borderRadius / 2

        // Workspace Switcher (Left)
        Rectangle {
            // 1. Make the background transparent and add a border
            color: Theme.surfaceTrough
            radius: Theme.borderRadius * 1.5

            // 2. Bind size to the inner Row's size + some padding
            Layout.preferredWidth: workspaceRow.width + 10  // 5px padding on left/right
            Layout.preferredHeight: workspaceRow.height + 10 // 5px padding on top/bottom

            Row {
                id: workspaceRow // Added an ID to reference its size above

                // Center the Row inside the border container
                anchors.centerIn: parent

                Layout.alignment: Qt.AlignVCenter
                spacing: 1

                Repeater {
                    model: Hyprland.workspaces
                    Rectangle {
                        id: wsRect
                        required property var modelData
                        width: 20
                        height: 20
                        radius: 20
                        color: wsRect.modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0) ? "#b4befe" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: wsRect.modelData.id
                            color: wsRect.modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0) ? "#11111b" : "#bac2de"
                        }
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
