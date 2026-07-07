import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../services"
import "../components"

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
    WeatherEngine {
        id: weatherService
    }

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.leftMargin: Theme.borderRadius / 2
        anchors.rightMargin: Theme.borderRadius / 2

        HyprWorkspaces {
            id: hyprWorkspaces
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: `${weatherService.currentForecast} | ${weatherService.currentTemp} ${weatherService.tempUnit}`
            color: "#b4befe"
        }

        AudioController {
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }

        // Active Title
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Desktop"
            color: "#cdd6f4"
        }
    }

    // Live Clock Component (Right)
    Text {
        Layout.alignment: Qt.AlignVCenter
        anchors.verticalCenterOffset: 4
        anchors.centerIn: barRoot
        text: clockService.timeString
        color: "#b4befe"
        font.bold: true
    }
}
