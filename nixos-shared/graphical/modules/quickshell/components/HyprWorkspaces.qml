pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../services"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.borderRadius * 1.5
    // border.color: Theme.borderColor
    // border.width: Theme.borderSize

    Layout.preferredWidth: workspaceRow.width + 16
    Layout.preferredHeight: 30

    // Track the active workspace ID at the root level reactively
    readonly property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    // Build a map of occupied workspace IDs reactively
    readonly property var occupiedWorkspaces: {
        var occupied = {};
        if (Hyprland.toplevels) {
            var vals = Hyprland.toplevels.values;
            for (var i = 0; i < vals.length; i++) {
                var tl = vals[i];
                if (tl.workspace) {
                    occupied[tl.workspace.id] = true;
                }
            }
        }
        return occupied;
    }

    // Build the list of workspace IDs to show: active workspace + occupied workspaces, sorted
    readonly property var workspaceList: {
        var list = [];
        var activeId = root.activeWsId;
        
        list.push(activeId);
        
        if (Hyprland.toplevels) {
            var vals = Hyprland.toplevels.values;
            for (var i = 0; i < vals.length; i++) {
                var tl = vals[i];
                if (tl.workspace && tl.workspace.id > 0) {
                    var wsId = tl.workspace.id;
                    if (list.indexOf(wsId) === -1) {
                        list.push(wsId);
                    }
                }
            }
        }
        
        list.sort(function(a, b) { return a - b; });
        return list;
    }

    // Activate/focus a workspace using its native object if possible, fallback to command dispatch
    function activateWorkspace(wsId) {
        if (Hyprland.workspaces) {
            var vals = Hyprland.workspaces.values;
            for (var i = 0; i < vals.length; i++) {
                var ws = vals[i];
                if (ws.id === wsId) {
                    ws.activate();
                    return;
                }
            }
        }
        Hyprland.dispatch("workspace " + wsId);
    }

    // Background mouse wheel handler for scrolling between pills
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: (wheel) => {
            if (wheel.angleDelta.y < 0) {
                Hyprland.dispatch("workspace e+1");
            } else if (wheel.angleDelta.y > 0) {
                Hyprland.dispatch("workspace e-1");
            }
        }
    }

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 8
        Layout.alignment: Qt.AlignVCenter

        Repeater {
            model: root.workspaceList

            delegate: Rectangle {
                id: wsRect
                required property int index
                required property int modelData

                readonly property int wsId: modelData
                readonly property bool isFocused: root.activeWsId === wsId
                readonly property bool isOccupied: !!root.occupiedWorkspaces[wsId]

                width: isFocused ? 20 : 12
                height: 12
                radius: 20

                color: isFocused ? Theme.primary : Theme.comment

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: wsRect.wsId
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: 8
                    font.bold: true
                    color: Theme.background
                    opacity: wsRect.isFocused ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                  anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    
                    onClicked: {
                        root.activateWorkspace(wsRect.wsId);
                    }

                    onWheel: (wheel) => {
                        if (wheel.angleDelta.y < 0) {
                            Hyprland.dispatch("workspace e+1");
                        } else if (wheel.angleDelta.y > 0) {
                            Hyprland.dispatch("workspace e-1");
                        }
                    }
                }
            }
        }
    }
}
