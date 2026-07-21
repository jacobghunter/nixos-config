import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../services"
import "../components"

PersonaRectangle {
    id: widgetRoot
    required property bool active

    // Persona-style dual border & background settings
    borderColor: Theme.primary
    backgroundColor: Theme.panelBackground
    borderWidth: 5.0

    roundingPower: 0

    backBorderExpansion: 6
    showBackBorder: true
    backBackgroundColor: Theme.secondary
    backBorderColor: Qt.rgba(0, 0, 0, 1)
    backBorderOffsetX: 0
    backBorderOffsetY: 0
    
    contentPadding: 12

    // Custom properties for toggles
    property bool wifiActive: true
    property bool bluetoothActive: false
    property bool dndActive: false
    property bool nightLightActive: true

    // Mock system stats
    property real cpuUsage: 0.18
    property real ramUsage: 0.54
    property real diskUsage: 0.62

    Timer {
        interval: 1500
        running: widgetRoot.active
        repeat: true
        onTriggered: {
            cpuUsage = Math.max(0.04, Math.min(0.85, cpuUsage + (Math.random() - 0.5) * 0.12))
            ramUsage = Math.max(0.48, Math.min(0.65, ramUsage + (Math.random() - 0.5) * 0.03))
        }
    }

    ClockEngine {
        id: clockService
    }

    WeatherEngine {
        id: weatherService
    }

    // Slide-down entrance animation
    y: active ? 0 : -15
    Behavior on y {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // 1. Header (Greeting & Weather)
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: {
                        let hour = new Date().getHours();
                        if (hour < 12) return "Good morning, Jacob!";
                        if (hour < 18) return "Good afternoon, Jacob!";
                        return "Good evening, Jacob!";
                    }
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 15
                    font.bold: true
                    color: "#f5e0dc" // Rosewater
                }

                Text {
                    text: {
                        let d = new Date();
                        let options = { weekday: 'short', month: 'short', day: 'numeric' };
                        return d.toLocaleDateString(undefined, options) + "  •  " + clockService.timeString;
                    }
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 11
                    color: Theme.foregroundMuted
                }
            }

            // Weather Pill
            Rectangle {
                height: 32
                implicitWidth: weatherLayout.implicitWidth + 16
                color: Theme.baseSelectionBackground
                radius: 16
                border.color: Theme.baseBorder
                RowLayout {
                    id: weatherLayout
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰖐"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 14
                        color: "#f9e2af" // Yellow
                    }

                    Text {
                        text: weatherService.currentTemp > 0 ? `${Math.round(weatherService.currentTemp)}°${weatherService.tempUnit}` : "Weather"
                        font.family: "Outfit, Inter, sans-serif"
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.foregroundBright
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.selectionBackground
        }

        // 2. Quick Settings Toggles (Grid)
        GridLayout {
            columns: 2
            rowSpacing: 10
            columnSpacing: 10
            Layout.fillWidth: true

            // WIFI
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 12
                color: wifiActive ? Qt.alpha(Theme.primary, Theme.colorAlpha) :  Theme.baseBackground
                border.color: wifiActive ? Theme.primary : Theme.baseBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: wifiActive ? "󰤨" : "󰤭"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 18
                        color: wifiActive ? Theme.primary : Theme.foregroundMuted
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Text {
                            text: "Wi-Fi"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.foreground
                        }
                        Text {
                            text: wifiActive ? "Connected" : "Off"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 9
                            color: Theme.foregroundMuted
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: wifiActive = !wifiActive
                }
            }

            // BLUETOOTH
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 12
                color: bluetoothActive ? Qt.alpha(Theme.secondary, Theme.colorAlpha) : Theme.baseBackground
                border.color: bluetoothActive ? Theme.secondary : Theme.baseBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: bluetoothActive ? "󰂯" : "󰂲"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 18
                        color: bluetoothActive ? Theme.secondary : Theme.foregroundMuted
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Text {
                            text: "Bluetooth"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.foreground
                        }
                        Text {
                            text: bluetoothActive ? "On" : "Off"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 9
                            color: Theme.foregroundMuted
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bluetoothActive = !bluetoothActive
                }
            }

            // DND
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 12
                color: dndActive ? Qt.alpha(Theme.error, Theme.colorAlpha) : Theme.baseBackground
                border.color: dndActive ? Theme.error : Theme.baseBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: dndActive ? "󰂛" : "󰂚"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 18
                        color: dndActive ? Theme.error : Theme.foregroundMuted
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Text {
                            text: "DND"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.foreground
                        }
                        Text {
                            text: dndActive ? "Muted" : "Off"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 9
                            color: Theme.foregroundMuted
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dndActive = !dndActive
                }
            }

            // NIGHT LIGHT
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 12
                color: nightLightActive ? Qt.alpha(Theme.warning, Theme.colorAlpha) : Theme.baseBackground
                border.color: nightLightActive ? Theme.warning : Theme.baseBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: nightLightActive ? "󰖔" : "󰖙"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 18
                        color: nightLightActive ? Theme.warning : Theme.foregroundMuted
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Text {
                            text: "Night Light"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.foreground
                        }
                        Text {
                            text: nightLightActive ? "Warm" : "Off"
                            font.family: "Outfit, Inter, sans-serif"
                            font.pixelSize: 9
                            color: Theme.foregroundMuted
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: nightLightActive = !nightLightActive
                }
            }
        }

        // 3. Audio Slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Volume"
                font.family: "Outfit, Inter, sans-serif"
                font.pixelSize: 11
                font.bold: true
                color: Theme.foregroundMuted
            }

            RowLayout {
                spacing: 10
                Layout.fillWidth: true

                Text {
                    text: Pipewire.defaultAudioSink?.audio?.muted ? "󰝟" : "󰕾"
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: 16
                    color: Pipewire.defaultAudioSink?.audio?.muted ? Theme.error : Theme.foregroundMuted

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                                Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
                            }
                        }
                    }
                }

                // Slider Track
                Rectangle {
                    id: sliderTrack
                    Layout.fillWidth: true
                    height: 6
                    color: Qt.rgba(1, 1, 1, 0.08)
                    radius: 3

                    Rectangle {
                        id: sliderFill
                        height: parent.height
                        width: parent.width * (Pipewire.defaultAudioSink?.audio?.muted ? 0 : (Pipewire.defaultAudioSink?.audio?.volume ?? 0))
                        color: "#a6e3a1"
                        radius: 3
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: Theme.foregroundBright
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(sliderTrack.width - width, sliderFill.width - width / 2))

                        Behavior on scale { NumberAnimation { duration: 100 } }
                        scale: sliderMouse.containsMouse ? 1.2 : 1.0
                    }

                    MouseArea {
                        id: sliderMouse
                        anchors.fill: parent
                        anchors.margins: -10
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        function updateVol(mouse) {
                            if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
                                let val = Math.max(0.0, Math.min(1.0, mouse.x / sliderTrack.width));
                                Pipewire.defaultAudioSink.audio.volume = val;
                                Pipewire.defaultAudioSink.audio.muted = false;
                            }
                        }
                        onPressed: (mouse) => updateVol(mouse)
                        onPositionChanged: (mouse) => {
                            if (pressed) updateVol(mouse)
                        }
                    }
                }

                Text {
                    text: Math.round((Pipewire.defaultAudioSink?.audio?.muted ? 0 : (Pipewire.defaultAudioSink?.audio?.volume ?? 0)) * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // 4. System Monitor Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "System Monitor"
                font.family: "Outfit, Inter, sans-serif"
                font.pixelSize: 11
                font.bold: true
                color: Theme.foregroundMuted
            }

            // CPU Stat Row
            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: "CPU"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foreground
                    Layout.preferredWidth: 32
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    radius: 2

                    Rectangle {
                        height: parent.height
                        width: parent.width * cpuUsage
                        color: "#cba6f7" // Mauve
                        radius: 2

                        Behavior on width {
                            NumberAnimation { duration: 300 }
                        }
                    }
                }

                Text {
                    text: Math.round(cpuUsage * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight
                }
            }

            // RAM Stat Row
            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: "MEM"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foreground
                    Layout.preferredWidth: 32
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    radius: 2

                    Rectangle {
                        height: parent.height
                        width: parent.width * ramUsage
                        color: "#89dceb" // Sky
                        radius: 2

                        Behavior on width {
                            NumberAnimation { duration: 300 }
                        }
                    }
                }

                Text {
                    text: Math.round(ramUsage * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight
                }
            }

            // Disk Stat Row
            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: "DISK"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foreground
                    Layout.preferredWidth: 32
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    radius: 2

                    Rectangle {
                        height: parent.height
                        width: parent.width * diskUsage
                        color: "#fab387" // Peach
                        radius: 2
                    }
                }

                Text {
                    text: Math.round(diskUsage * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
