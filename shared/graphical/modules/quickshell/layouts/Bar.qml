import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../services"
import "../components"
import qs.lib as GlobalTheme


// FIX: Make the root element the actual visual Rectangle
Rectangle {
    id: barRoot
    implicitHeight: mainLayout.implicitHeight

    signal dashboardToggleRequested()
    signal launcherToggleRequested()

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

        ActiveWindow {
            id: activeWindow
            Layout.alignment: Qt.AlignVCenter
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

        // Dashboard launcher button
        Rectangle {
            id: dashboardButton
            Layout.alignment: Qt.AlignVCenter
            height: 30
            width: dashboardIcon.width + 12
            radius: Theme.borderRadius
            color: dashboardMouse.containsMouse ? "#1affffff" : "transparent"
            border.color: dashboardMouse.containsMouse ? Theme.borderColor : "transparent"
            border.width: Theme.borderSize

            Text {
                id: dashboardIcon
                anchors.centerIn: parent
                text: ""
                font.family: "Iosevka Nerd Font"
                font.pixelSize: 13
                color: "#b4befe"
            }

            MouseArea {
                id: dashboardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: barRoot.dashboardToggleRequested()
            }
        }

        // App launcher button
        Rectangle {
            id: launcherButton
            Layout.alignment: Qt.AlignVCenter
            height: 30
            width: launcherIcon.width + 12
            radius: Theme.borderRadius
            color: launcherMouse.containsMouse ? "#1affffff" : "transparent"
            border.color: launcherMouse.containsMouse ? Theme.borderColor : "transparent"
            border.width: Theme.borderSize

            Text {
                id: launcherIcon
                anchors.centerIn: parent
                text: ""
                font.family: "Iosevka Nerd Font"
                font.pixelSize: 13
                color: "#b4befe"
            }

            MouseArea {
                id: launcherMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: barRoot.launcherToggleRequested()
            }
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
