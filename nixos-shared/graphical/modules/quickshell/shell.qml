import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "./layouts" as Layouts
import "./services/Theme.qml" as Theme
import "./components" as Components
import "./widgets" as Widgets

ShellRoot {
    id: root

    property bool dashboardVisible: false

    IpcHandler {
        target: "dashboard"
        function toggle(): void {
            root.dashboardVisible = !root.dashboardVisible;
        }
    }

    property bool launcherVisible: false

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            root.launcherVisible = !root.launcherVisible;
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

            visible: content.opacity > 0

            anchors {
                top: true
                right: true
            }

            margins {
                top: 52
                right: 12
            }

            width: 320
            height: 420
            exclusionMode: ExclusionMode.Ignore

            Item {
                id: content
                anchors.fill: parent
                opacity: root.dashboardVisible ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Widgets.Dashboard {
                    anchors.fill: parent
                    active: root.dashboardVisible
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: launcherWindow
            required property var modelData
            screen: modelData
            color: "transparent"

            visible: launcherContent.opacity > 0

            anchors {
                top: false
                bottom: false
                left: false
                right: false
            }

            width: 640
            height: 480

            WlrLayershell.keyboardFocus: root.launcherVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore

            Item {
                id: launcherContent
                anchors.fill: parent
                opacity: root.launcherVisible ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                Widgets.Launcher {
                    anchors.fill: parent
                    active: root.launcherVisible
                }
            }
        }
    }
}
