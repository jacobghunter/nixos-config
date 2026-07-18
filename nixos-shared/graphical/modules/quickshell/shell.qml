// shell.qml
import Quickshell
import QtQuick
import "./layouts" as Layouts
import "./services/Theme.qml" as Theme

ShellRoot {
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
}
