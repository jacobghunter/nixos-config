pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../services"

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
