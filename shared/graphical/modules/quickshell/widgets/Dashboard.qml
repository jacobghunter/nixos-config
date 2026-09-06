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

    showDoubleBorder: true
    doubleBorderColor: Qt.rgba(0, 0, 0, 1)
    doubleBorderWidth: 3
    doubleBorderOffset: 2

    roundingPower: 0
    backRoundingPower: 0

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

    // Active tiles get a bold color block, not a soft tint - reads at a glance
    readonly property real tileActiveAlpha: 0.5

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

    // Flashed by the border's jitter beat so a piece of content visibly shares
    // its pulse with the frame instead of sitting inert inside it.
    Timer {
        id: weatherPillFlashTimer
        interval: 80
        onTriggered: weatherPillBorder.flashPulse = false
    }
    onJittered: {
        weatherPillBorder.flashPulse = true;
        weatherPillFlashTimer.restart();
    }

    // Structural Persona motif: a bold diagonal band cutting behind the header,
    // asymmetric and static - contrasts with the jittering border/content without
    // competing for motion budget.
    Item {
        anchors.fill: parent
        clip: true
        z: -1

        Rectangle {
            width: parent.width * 1.6
            height: 54
            color: Qt.alpha(Theme.primary, 0.14)
            rotation: -7
            x: -parent.width * 0.3
            y: 18
        }
        Rectangle {
            width: parent.width * 1.6
            height: 10
            color: Qt.alpha(Theme.secondary, 0.5)
            rotation: -7
            x: -parent.width * 0.3
            y: 66
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
                    color: Theme.foregroundBright
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
                id: weatherPillBorder
                property bool flashPulse: false

                height: 32
                implicitWidth: weatherLayout.implicitWidth + 16
                color: Theme.baseSelectionBackground
                radius: 16
                border.color: flashPulse ? Theme.primary : Theme.baseBorder
                Behavior on border.color {
                    ColorAnimation { duration: weatherPillBorder.flashPulse ? 80 : 420; easing.type: Easing.OutCubic }
                }

                RowLayout {
                    id: weatherLayout
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰖐"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 14
                        color: Theme.warning
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
            // NOTE: the outer Rectangle is a stable, non-transformed hit-frame for the
            // MouseArea. Rotation/scale live on the inner "skin" instead of on the tile
            // that owns the MouseArea - animating the hover target's own hit-box creates
            // a feedback loop (the tile rotates out from under the cursor, hover drops,
            // it snaps back, hover re-triggers, repeat) which reads as "hover is broken".
            Rectangle {
                id: wifiTile
                Layout.fillWidth: true
                height: 52
                color: "transparent"

                opacity: widgetRoot.active ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                // transform (not y) so GridLayout keeps controlling actual position
                transform: Translate {
                    y: widgetRoot.active ? 0 : 36
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                }

                Rectangle {
                    id: wifiSkin
                    anchors.fill: parent
                    radius: 12
                    color: wifiActive ? Qt.alpha(Theme.primary, tileActiveAlpha) : Theme.baseBackground
                    border.color: wifiActive ? Theme.primary : Theme.baseBorder
                    border.width: wifiActive ? 2 : 1
                    scale: wifiMouse.containsMouse ? 1.05 : 1.0
                    rotation: wifiMouse.containsMouse ? -7 : 0

                    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

                    // Click strobe - quick bright flash under the content
                    Rectangle {
                        id: wifiFlash
                        anchors.fill: parent
                        radius: parent.radius
                        color: Theme.primary
                        opacity: 0
                        SequentialAnimation {
                            id: wifiFlashAnim
                            NumberAnimation { target: wifiFlash; property: "opacity"; to: 0.45; duration: 50 }
                            NumberAnimation { target: wifiFlash; property: "opacity"; to: 0; duration: 240; easing.type: Easing.OutCubic }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            id: wifiIcon
                            text: wifiActive ? "󰤨" : "󰤭"
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: 18
                            color: wifiActive ? Theme.primary : Theme.foregroundMuted
                            Behavior on color { ColorAnimation { duration: 200 } }

                            SequentialAnimation {
                                id: wifiPunch
                                ParallelAnimation {
                                    NumberAnimation { target: wifiIcon; property: "scale"; to: 1.4; duration: 90; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: wifiIcon; property: "rotation"; to: wifiActive ? 18 : -18; duration: 90; easing.type: Easing.OutQuad }
                                }
                                ParallelAnimation {
                                    NumberAnimation { target: wifiIcon; property: "scale"; to: 1.0; duration: 180; easing.type: Easing.OutBack }
                                    NumberAnimation { target: wifiIcon; property: "rotation"; to: 0; duration: 180; easing.type: Easing.OutBack }
                                }
                            }
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
                }

                MouseArea {
                    id: wifiMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { wifiActive = !wifiActive; wifiPunch.restart(); wifiFlashAnim.restart(); }
                }
            }

            // BLUETOOTH
            Rectangle {
                id: bluetoothTile
                Layout.fillWidth: true
                height: 52
                color: "transparent"

                opacity: widgetRoot.active ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 230; easing.type: Easing.OutCubic } }

                transform: Translate {
                    y: widgetRoot.active ? 0 : 36
                    Behavior on y { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
                }

                Rectangle {
                    id: bluetoothSkin
                    anchors.fill: parent
                    radius: 12
                    color: bluetoothActive ? Qt.alpha(Theme.secondary, tileActiveAlpha) : Theme.baseBackground
                    border.color: bluetoothActive ? Theme.secondary : Theme.baseBorder
                    border.width: bluetoothActive ? 2 : 1
                    scale: bluetoothMouse.containsMouse ? 1.05 : 1.0
                    rotation: bluetoothMouse.containsMouse ? -7 : 0

                    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

                    Rectangle {
                        id: bluetoothFlash
                        anchors.fill: parent
                        radius: parent.radius
                        color: Theme.secondary
                        opacity: 0
                        SequentialAnimation {
                            id: bluetoothFlashAnim
                            NumberAnimation { target: bluetoothFlash; property: "opacity"; to: 0.45; duration: 50 }
                            NumberAnimation { target: bluetoothFlash; property: "opacity"; to: 0; duration: 240; easing.type: Easing.OutCubic }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            id: bluetoothIcon
                            text: bluetoothActive ? "󰂯" : "󰂲"
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: 18
                            color: bluetoothActive ? Theme.secondary : Theme.foregroundMuted
                            Behavior on color { ColorAnimation { duration: 200 } }

                            SequentialAnimation {
                                id: bluetoothPunch
                                ParallelAnimation {
                                    NumberAnimation { target: bluetoothIcon; property: "scale"; to: 1.4; duration: 90; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: bluetoothIcon; property: "rotation"; to: bluetoothActive ? 18 : -18; duration: 90; easing.type: Easing.OutQuad }
                                }
                                ParallelAnimation {
                                    NumberAnimation { target: bluetoothIcon; property: "scale"; to: 1.0; duration: 180; easing.type: Easing.OutBack }
                                    NumberAnimation { target: bluetoothIcon; property: "rotation"; to: 0; duration: 180; easing.type: Easing.OutBack }
                                }
                            }
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
                }

                MouseArea {
                    id: bluetoothMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { bluetoothActive = !bluetoothActive; bluetoothPunch.restart(); bluetoothFlashAnim.restart(); }
                }
            }

            // DND
            Rectangle {
                id: dndTile
                Layout.fillWidth: true
                height: 52
                color: "transparent"

                opacity: widgetRoot.active ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

                transform: Translate {
                    y: widgetRoot.active ? 0 : 36
                    Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
                }

                Rectangle {
                    id: dndSkin
                    anchors.fill: parent
                    radius: 12
                    color: dndActive ? Qt.alpha(Theme.error, tileActiveAlpha) : Theme.baseBackground
                    border.color: dndActive ? Theme.error : Theme.baseBorder
                    border.width: dndActive ? 2 : 1
                    scale: dndMouse.containsMouse ? 1.05 : 1.0
                    rotation: dndMouse.containsMouse ? -7 : 0

                    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

                    Rectangle {
                        id: dndFlash
                        anchors.fill: parent
                        radius: parent.radius
                        color: Theme.error
                        opacity: 0
                        SequentialAnimation {
                            id: dndFlashAnim
                            NumberAnimation { target: dndFlash; property: "opacity"; to: 0.45; duration: 50 }
                            NumberAnimation { target: dndFlash; property: "opacity"; to: 0; duration: 240; easing.type: Easing.OutCubic }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            id: dndIcon
                            text: dndActive ? "󰂛" : "󰂚"
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: 18
                            color: dndActive ? Theme.error : Theme.foregroundMuted
                            Behavior on color { ColorAnimation { duration: 200 } }

                            SequentialAnimation {
                                id: dndPunch
                                ParallelAnimation {
                                    NumberAnimation { target: dndIcon; property: "scale"; to: 1.4; duration: 90; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: dndIcon; property: "rotation"; to: dndActive ? 18 : -18; duration: 90; easing.type: Easing.OutQuad }
                                }
                                ParallelAnimation {
                                    NumberAnimation { target: dndIcon; property: "scale"; to: 1.0; duration: 180; easing.type: Easing.OutBack }
                                    NumberAnimation { target: dndIcon; property: "rotation"; to: 0; duration: 180; easing.type: Easing.OutBack }
                                }
                            }
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
                }

                MouseArea {
                    id: dndMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { dndActive = !dndActive; dndPunch.restart(); dndFlashAnim.restart(); }
                }
            }

            // NIGHT LIGHT
            Rectangle {
                id: nightLightTile
                Layout.fillWidth: true
                height: 52
                color: "transparent"

                opacity: widgetRoot.active ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 290; easing.type: Easing.OutCubic } }

                transform: Translate {
                    y: widgetRoot.active ? 0 : 36
                    Behavior on y { NumberAnimation { duration: 290; easing.type: Easing.OutBack } }
                }

                Rectangle {
                    id: nightLightSkin
                    anchors.fill: parent
                    radius: 12
                    color: nightLightActive ? Qt.alpha(Theme.warning, tileActiveAlpha) : Theme.baseBackground
                    border.color: nightLightActive ? Theme.warning : Theme.baseBorder
                    border.width: nightLightActive ? 2 : 1
                    scale: nightLightMouse.containsMouse ? 1.05 : 1.0
                    rotation: nightLightMouse.containsMouse ? -7 : 0

                    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on border.width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

                    Rectangle {
                        id: nightLightFlash
                        anchors.fill: parent
                        radius: parent.radius
                        color: Theme.warning
                        opacity: 0
                        SequentialAnimation {
                            id: nightLightFlashAnim
                            NumberAnimation { target: nightLightFlash; property: "opacity"; to: 0.45; duration: 50 }
                            NumberAnimation { target: nightLightFlash; property: "opacity"; to: 0; duration: 240; easing.type: Easing.OutCubic }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            id: nightLightIcon
                            text: nightLightActive ? "󰖔" : "󰖙"
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: 18
                            color: nightLightActive ? Theme.warning : Theme.foregroundMuted
                            Behavior on color { ColorAnimation { duration: 200 } }

                            SequentialAnimation {
                                id: nightLightPunch
                                ParallelAnimation {
                                    NumberAnimation { target: nightLightIcon; property: "scale"; to: 1.4; duration: 90; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: nightLightIcon; property: "rotation"; to: nightLightActive ? 18 : -18; duration: 90; easing.type: Easing.OutQuad }
                                }
                                ParallelAnimation {
                                    NumberAnimation { target: nightLightIcon; property: "scale"; to: 1.0; duration: 180; easing.type: Easing.OutBack }
                                    NumberAnimation { target: nightLightIcon; property: "rotation"; to: 0; duration: 180; easing.type: Easing.OutBack }
                                }
                            }
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
                }

                MouseArea {
                    id: nightLightMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { nightLightActive = !nightLightActive; nightLightPunch.restart(); nightLightFlashAnim.restart(); }
                }
            }
        }

        // 3. Audio Slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                spacing: 6
                Rectangle {
                    width: 8
                    height: 11
                    color: Theme.success
                    rotation: -14
                }
                Text {
                    text: "Volume"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 11
                    font.bold: true
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1.5
                    color: Theme.foregroundMuted
                }
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
                    color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.08)
                    radius: 3

                    Rectangle {
                        id: sliderFill
                        height: parent.height
                        width: parent.width * (Pipewire.defaultAudioSink?.audio?.muted ? 0 : (Pipewire.defaultAudioSink?.audio?.volume ?? 0))
                        color: Theme.success
                        radius: 3

                        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                        // Idle breathing glow at the leading edge - keeps the bar alive at rest
                        Rectangle {
                            width: 5
                            height: parent.height
                            radius: 2.5
                            visible: sliderFill.width > width
                            x: parent.width - width
                            color: Theme.foregroundBright
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 650; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.35; duration: 650; easing.type: Easing.InOutSine }
                            }
                        }
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
                    id: volumeLabel
                    text: Math.round((Pipewire.defaultAudioSink?.audio?.muted ? 0 : (Pipewire.defaultAudioSink?.audio?.volume ?? 0)) * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight

                    Behavior on color { ColorAnimation { duration: 300 } }
                    onTextChanged: { color = Theme.success; volumeFlashReset.restart(); }
                    Timer { id: volumeFlashReset; interval: 50; onTriggered: volumeLabel.color = Theme.foregroundMuted }
                }
            }
        }

        // 4. System Monitor Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                spacing: 6
                Rectangle {
                    width: 8
                    height: 11
                    color: Theme.accent
                    rotation: -14
                }
                Text {
                    text: "System Monitor"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 11
                    font.bold: true
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1.5
                    color: Theme.foregroundMuted
                }
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
                    color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.08)
                    radius: 2

                    Rectangle {
                        id: cpuFill
                        height: parent.height
                        width: parent.width * cpuUsage
                        color: Theme.accent
                        radius: 2

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            width: 4
                            height: parent.height
                            radius: 2
                            visible: cpuFill.width > width
                            x: parent.width - width
                            color: Theme.foregroundBright
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 550; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.35; duration: 550; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }

                Text {
                    id: cpuLabel
                    text: Math.round(cpuUsage * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight

                    Behavior on color { ColorAnimation { duration: 300 } }
                    onTextChanged: { color = Theme.accent; cpuFlashReset.restart(); }
                    Timer { id: cpuFlashReset; interval: 50; onTriggered: cpuLabel.color = Theme.foregroundMuted }
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
                    color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.08)
                    radius: 2

                    Rectangle {
                        id: ramFill
                        height: parent.height
                        width: parent.width * ramUsage
                        color: Theme.info
                        radius: 2

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            width: 4
                            height: parent.height
                            radius: 2
                            visible: ramFill.width > width
                            x: parent.width - width
                            color: Theme.foregroundBright
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 550; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.35; duration: 550; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }

                Text {
                    id: ramLabel
                    text: Math.round(ramUsage * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight

                    Behavior on color { ColorAnimation { duration: 300 } }
                    onTextChanged: { color = Theme.info; ramFlashReset.restart(); }
                    Timer { id: ramFlashReset; interval: 50; onTriggered: ramLabel.color = Theme.foregroundMuted }
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
                    color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.08)
                    radius: 2

                    Rectangle {
                        id: diskFill
                        height: parent.height
                        width: parent.width * diskUsage
                        color: Theme.warning
                        radius: 2

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            width: 4
                            height: parent.height
                            radius: 2
                            visible: diskFill.width > width
                            x: parent.width - width
                            color: Theme.foregroundBright
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 550; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.35; duration: 550; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }

                Text {
                    id: diskLabel
                    text: Math.round(diskUsage * 100) + "%"
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 10
                    color: Theme.foregroundMuted
                    Layout.preferredWidth: 28
                    horizontalAlignment: Text.AlignRight

                    Behavior on color { ColorAnimation { duration: 300 } }
                    onTextChanged: { color = Theme.warning; diskFlashReset.restart(); }
                    Timer { id: diskFlashReset; interval: 50; onTriggered: diskLabel.color = Theme.foregroundMuted }
                }
            }
        }
    }
}
