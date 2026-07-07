pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../services"

Rectangle {
    color: Theme.surfaceTrough
    radius: Theme.borderRadius * 1.5

    Layout.preferredWidth: workspaceRow.width + 10
    Layout.preferredHeight: workspaceRow.height + 10

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        Layout.alignment: Qt.AlignVCenter
        spacing: 1

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: wsRect
                required property var modelData
                width: 20
                height: 20
                radius: 20
                color: Hyprland.focusedWorkspace && wsRect.modelData.id === Hyprland.focusedWorkspace.id ? "#b4befe" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: wsRect.modelData.id
                    color: Hyprland.focusedWorkspace && wsRect.modelData.id === Hyprland.focusedWorkspace.id ? "#11111b" : "#bac2de"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    // FIX: Call the native workspace object's activation method directly
                    onClicked: wsRect.modelData.activate()
                }
            }
        }
    }
}
