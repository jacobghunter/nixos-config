import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: barRoot
    // Premium dark glassmorphism
    color: "#d911111b" // Semi-transparent deep dark crust
    border.color: "#26cdd6f4" // Subtle lavender border
    border.width: 1
    radius: 8

    // Layout for bar contents
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        // Workspace Switcher (Left)
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Repeater {
                model: Hyprland.workspaces

                Rectangle {
                    required property var modelData

                    width: 26
                    height: 26
                    radius: 6
                    color: modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0) ? "#b4befe" // Lavender
                    : "#1e1e2e" // Surface

                    border.color: modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0) ? "#b4befe" : "#313244"
                    border.width: 1

                    Text {
                        required property var modelData

                        anchors.centerIn: parent
                        text: modelData.id
                        color: modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0) ? "#11111b" : "#bac2de"
                        font.bold: true
                        font.pixelSize: 12
                        font.family: "sans-serif"
                    }

                    MouseArea {
                        required property var modelData

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Hyprland.dispatch("workspace " + modelData.id);
                        }
                    }
                }
            }
        }

        // Spacer to center the title
        Item {
            Layout.fillWidth: true
        }

        // Active Window Title (Center)
        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: parent.width * 0.4
            text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Desktop"
            color: "#cdd6f4" // Soft white/lavender
            font.pixelSize: 13
            font.family: "sans-serif"
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // Live Clock (Right)
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            Text {
                id: clockText
                color: "#b4befe" // Lavender accent
                font.pixelSize: 13
                font.bold: true
                font.family: "sans-serif"

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        var date = new Date();
                        clockText.text = date.toLocaleTimeString(Qt.locale(), "hh:mm:ss AP");
                    }
                    Component.onCompleted: {
                        var date = new Date();
                        clockText.text = date.toLocaleTimeString(Qt.locale(), "hh:mm:ss AP");
                    }
                }
            }
        }
    }
}
