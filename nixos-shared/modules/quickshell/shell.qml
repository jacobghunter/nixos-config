import Quickshell
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            property var modelData: modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            exclusionMode: ExclusionMode.Auto

            Loader {
                anchors.fill: parent
                anchors.margins: 6
                height: 38
                source: "./Bar.qml"
            }
        }
    }
}
