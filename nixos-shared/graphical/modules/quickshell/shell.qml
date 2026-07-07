// shell.qml
import Quickshell
import QtQuick
import "./components" as Components // Import your local directory

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

            Components.Bar {
                id: mainBar
                anchors.fill: parent
                anchors.margins: 6
            }
        }
    }
}
