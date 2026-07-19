import Quickshell
import QtQuick
import Quickshell.Hyprland
import "./layouts" as Layouts
import "./services/Theme.qml" as Theme
import "./components" as Components

ShellRoot {
    id: root

    property bool widgetVisible: false

    IpcHandler {
        target: "dashboard"
        function toggle(): void {
            root.widgetVisible = !root.widgetVisible;
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            height: mainBar.implicitHeight + 6
            exclusionMode: ExclusionMode.Auto

            Layouts.Bar {
                id: mainBar
                anchors.fill: parent
                anchors.margins: 6
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: widgetWindow
            required property var modelData
            screen: modelData
            color: "transparent"

            visible: opacity > 0 || root.widgetVisible
            opacity: root.widgetVisible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            anchors {
                top: true
                right: true
            }
            anchors.topMargin: 52
            anchors.rightMargin: 12

            width: 320
            height: 420
            exclusionMode: ExclusionMode.None

            Components.QuickWidget {
                anchors.fill: parent
                active: root.widgetVisible
            }
        }
    }
}
