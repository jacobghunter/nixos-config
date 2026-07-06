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

            implicitHeight: 44
            exclusionMode: ExclusionMode.Auto

            Components.Bar {
                anchors.fill: parent
                anchors.margins: 6
            }
        }
    }
}
