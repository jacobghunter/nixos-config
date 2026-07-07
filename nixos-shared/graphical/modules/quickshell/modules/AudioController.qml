pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import "../modules"

Item {
    id: root
    implicitWidth: barButton.width
    implicitHeight: 30

    // List of sinks and sources
    property list<PwNode> sinks: []
    property list<PwNode> sources: []

    readonly property PwNode activeSink: Pipewire.defaultAudioSink
    readonly property PwNode activeSource: Pipewire.defaultAudioSource

    readonly property real volume: activeSink?.audio?.volume ?? 0
    readonly property bool muted: !!activeSink?.audio?.muted

    readonly property real sourceVolume: activeSource?.audio?.volume ?? 0
    readonly property bool sourceMuted: !!activeSource?.audio?.muted

    // Helper functions for volume changes
    function adjustVolume(amount: real): void {
        if (activeSink && activeSink.audio) {
            activeSink.audio.muted = false;
            activeSink.audio.volume = Math.max(0, Math.min(1.0, volume + amount));
        }
    }

    function toggleMute(): void {
        if (activeSink && activeSink.audio) {
            activeSink.audio.muted = !activeSink.audio.muted;
        }
    }

    function toggleSourceMute(): void {
        if (activeSource && activeSource.audio) {
            activeSource.audio.muted = !activeSource.audio.muted;
        }
    }

    Connections {
        target: Pipewire.nodes
        function onValuesChanged(): void {
            updateLists();
        }
    }

    function updateLists(): void {
        const newSinks = [];
        const newSources = [];
        for (const node of Pipewire.nodes.values) {
            if (!node.isStream) {
                if (node.isSink) {
                    newSinks.push(node);
                } else if (node.audio) {
                    newSources.push(node);
                }
            }
        }
        root.sinks = newSinks;
        root.sources = newSources;
    }

    // Initialize lists on completed
    Component.onCompleted: {
        updateLists();
    }

    // Visual button in the bar
    Rectangle {
        id: barButton
        height: parent.height
        width: buttonContent.width + 16
        color: buttonMouseArea.containsMouse ? "#1affffff" : "transparent"
        border.color: buttonMouseArea.containsMouse ? Theme.borderColor : "transparent"
        border.width: Theme.borderSize
        radius: Theme.borderRadius

        Row {
            id: buttonContent
            anchors.centerIn: parent
            spacing: 6

            Text {
                font.family: "Iosevka Nerd Font"
                font.pixelSize: 14
                color: root.muted ? "#f38ba8" : "#b4befe"
                text: {
                    if (root.muted)
                        return "󰖁";
                    const desc = root.activeSink?.description?.toLowerCase() || "";
                    if (desc.includes("headset") || desc.includes("headphones") || desc.includes("headphone")) {
                        return "󰋎";
                    }
                    if (root.volume > 0.6)
                        return "󰕾";
                    if (root.volume > 0.2)
                        return "󰖀";
                    return "󰕿";
                }
            }

            Text {
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                color: root.muted ? "#f38ba8" : "#bac2de"
                text: root.muted ? "Muted" : `${Math.round(root.volume * 100)}%`
            }
        }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: popupWindow.visible = !popupWindow.visible
            onWheel: event => {
                if (event.angleDelta.y > 0) {
                    root.adjustVolume(0.05);
                } else if (event.angleDelta.y < 0) {
                    root.adjustVolume(-0.05);
                }
            }
        }
    }

    // Popup Window for Device Switcher
    PanelWindow {
        id: popupWindow
        visible: false
        screen: barWindow.screen

        WlrLayershell.namespace: "qs-volume-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        focusable: true
        color: "transparent"

        // Dynamic positioning below the bar button
        anchors {
            top: true
            left: true
        }
        margins.top: barWindow.height + 6
        margins.left: {
            var btnX = barButton.mapToItem(barRoot, 0, 0).x + 6;
            // Center the popup on the button
            var targetX = btnX + (barButton.width / 2) - (popupWindow.width / 2);
            // Clamp to screen boundaries to prevent going off-screen
            var minX = 10;
            var maxX = barWindow.screen.width - popupWindow.width - 10;
            return Math.max(minX, Math.min(maxX, targetX));
        }

        implicitWidth: 320
        implicitHeight: popupLayout.implicitHeight + 24

        onVisibleChanged: {
            if (visible) {
                popupContainer.forceActiveFocus();
            }
        }

        Rectangle {
            id: popupContainer
            anchors.fill: parent
            color: Theme.surfaceDark
            border.color: Theme.borderColor
            border.width: Theme.borderSize
            radius: Theme.borderRadius * 1.5
            clip: true
            focus: true

            // Dismiss when focus lost
            onActiveFocusChanged: {
                if (!activeFocus) {
                    popupWindow.visible = false;
                }
            }

            ColumnLayout {
                id: popupLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Header
                Text {
                    text: "Audio Control"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.text
                }

                // Volume slider section
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 16
                        color: root.muted ? "#f38ba8" : "#b4befe"
                        text: root.muted ? "󰖁" : "󰕾"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleMute()
                        }
                    }

                    // Custom Slider track and handle
                    Item {
                        id: volumeSlider
                        Layout.fillWidth: true
                        implicitHeight: 16

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: "#20ffffff"
                            border.color: "#10ffffff"
                            border.width: 1

                            Rectangle {
                                height: parent.height
                                width: parent.width * root.volume
                                radius: 8
                                color: root.muted ? "#595959" : "#ce00ff"

                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0.0
                                        color: root.muted ? "#595959" : "#ce00ff"
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: root.muted ? "#777777" : "#00dbff"
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            function updateVolume(mouse) {
                                var percentage = Math.max(0.0, Math.min(1.0, mouse.x / width));
                                if (root.activeSink && root.activeSink.audio) {
                                    root.activeSink.audio.muted = false;
                                    root.activeSink.audio.volume = percentage;
                                }
                            }

                            onPressed: mouse => updateVolume(mouse)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    updateVolume(mouse);
                            }
                        }
                    }

                    Text {
                        text: `${Math.round(root.volume * 100)}%`
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        color: Theme.text
                        Layout.preferredWidth: 35
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.borderColor
                }

                // Sinks (Output) switcher list
                Text {
                    text: "Output Devices"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#a6adc8"
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: root.sinks
                        delegate: Rectangle {
                            id: sinkItem
                            required property PwNode modelData
                            width: parent.width
                            height: 32
                            radius: Theme.borderRadius
                            color: {
                                if (root.activeSink?.id === sinkItem.modelData.id) {
                                    return "#313244";
                                }
                                return itemMouseArea.containsMouse ? "#1affffff" : "transparent";
                            }
                            border.color: root.activeSink?.id === sinkItem.modelData.id ? "#b4befe" : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Text {
                                    font.family: "Iosevka Nerd Font"
                                    font.pixelSize: 14
                                    color: root.activeSink?.id === sinkItem.modelData.id ? "#b4befe" : "#bac2de"
                                    text: {
                                        const desc = sinkItem.modelData.description?.toLowerCase() || "";
                                        if (desc.includes("headset") || desc.includes("headphones") || desc.includes("headphone"))
                                            return "󰋎";
                                        return "󰓃";
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: sinkItem.modelData.description || sinkItem.modelData.name || "Unknown Output"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                    color: root.activeSink?.id === sinkItem.modelData.id ? Theme.text : "#a6adc8"
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: "󰄲"
                                    font.family: "Iosevka Nerd Font"
                                    font.pixelSize: 12
                                    color: "#a6e3a1"
                                    visible: root.activeSink?.id === sinkItem.modelData.id
                                }
                            }

                            MouseArea {
                                id: itemMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Pipewire.preferredDefaultAudioSink = sinkItem.modelData
                            }
                        }
                    }
                }

                // Sources (Input) switcher list
                Text {
                    text: "Input Devices"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#a6adc8"
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: root.sources
                        delegate: Rectangle {
                            id: sourceItem
                            required property PwNode modelData
                            width: parent.width
                            height: 32
                            radius: Theme.borderRadius
                            color: {
                                if (root.activeSource?.id === sourceItem.modelData.id) {
                                    return "#313244";
                                }
                                return inputMouseArea.containsMouse ? "#1affffff" : "transparent";
                            }
                            border.color: root.activeSource?.id === sourceItem.modelData.id ? "#b4befe" : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Text {
                                    font.family: "Iosevka Nerd Font"
                                    font.pixelSize: 14
                                    color: root.activeSource?.id === sourceItem.modelData.id ? "#b4befe" : "#bac2de"
                                    text: "󰍬"
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: sourceItem.modelData.description || sourceItem.modelData.name || "Unknown Input"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                    color: root.activeSource?.id === sourceItem.modelData.id ? Theme.text : "#a6adc8"
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: "󰄲"
                                    font.family: "Iosevka Nerd Font"
                                    font.pixelSize: 12
                                    color: "#a6e3a1"
                                    visible: root.activeSource?.id === sourceItem.modelData.id
                                }
                            }

                            MouseArea {
                                id: inputMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Pipewire.preferredDefaultAudioSource = sourceItem.modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
