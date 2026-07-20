import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../services"

Base {
    id: launcherRoot
    required property bool active

    implicitWidth: 640
    implicitHeight: 480
    borderWidth: 1
    radius: 24
    padding: 16

    // Theme values (using Base's bgColor/borderColor default or customized)
    bgColor: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.9)
    borderColor: Theme.baseBorder

    property string searchText: ""
    property int selectedIndex: 0

    // Filtered list of desktop applications
    readonly property var filteredApps: {
        let query = searchText.toLowerCase().trim();
        let apps = DesktopEntries.applications.filter(app => !app.noDisplay);
        
        if (query === "") return apps;
        
        return apps.filter(app => {
            let nameMatch = app.name.toLowerCase().includes(query);
            let commentMatch = app.comment && app.comment.toLowerCase().includes(query);
            return nameMatch || commentMatch;
        });
    }

    // Reset selection and focus when launcher is toggled on
    onActiveChanged: {
        if (active) {
            searchText = "";
            selectedIndex = 0;
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    // Force focus to the input box if user clicks anywhere on the launcher
    MouseArea {
        anchors.fill: parent
        onClicked: searchInput.forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Search Bar Area
        Rectangle {
            Layout.fillWidth: true
            height: 52
            radius: 16
            color: Qt.rgba(1, 1, 1, 0.04)
            border.color: searchInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.08)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                // Search Icon
                Text {
                    text: "󰍉"
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: 18
                    color: searchInput.activeFocus ? Theme.primary : Theme.foregroundMuted
                }

                // TextInput
                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    font.family: "Outfit, Inter, sans-serif"
                    font.pixelSize: 15
                    color: Theme.foreground
                    focus: true
                    
                    // Placeholder Text
                    Text {
                        text: "Search applications..."
                        font.family: parent.font.family
                        font.pixelSize: parent.font.pixelSize
                        color: Theme.foregroundMuted
                        visible: searchInput.text === "" && !searchInput.activeFocus
                    }

                    onTextChanged: {
                        launcherRoot.searchText = text;
                        launcherRoot.selectedIndex = 0;
                    }

                    // Key navigation handling
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down) {
                            if (launcherRoot.filteredApps.length > 0) {
                                launcherRoot.selectedIndex = (launcherRoot.selectedIndex + 1) % launcherRoot.filteredApps.length;
                                appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain);
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            if (launcherRoot.filteredApps.length > 0) {
                                launcherRoot.selectedIndex = (launcherRoot.selectedIndex - 1 + launcherRoot.filteredApps.length) % launcherRoot.filteredApps.length;
                                appList.positionViewAtIndex(launcherRoot.selectedIndex, ListView.Contain);
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return) {
                            if (launcherRoot.filteredApps.length > 0 && launcherRoot.selectedIndex < launcherRoot.filteredApps.length) {
                                let selectedApp = launcherRoot.filteredApps[launcherRoot.selectedIndex];
                                selectedApp.execute();
                                // Toggle visibility state on shell.qml
                                root.launcherVisible = false; 
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            root.launcherVisible = false;
                            event.accepted = true;
                        }
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.08)
        }

        // App List
        ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: launcherRoot.filteredApps

            delegate: Item {
                id: delegateItem
                width: ListView.view.width
                height: 56

                readonly property bool isSelected: index === launcherRoot.selectedIndex

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: isSelected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                    border.color: isSelected ? Theme.primary : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 16

                        // Application Icon (via IconImage)
                        IconImage {
                            id: appIcon
                            implicitSize: 32
                            source: modelData.icon || "application-x-executable"
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // App Metadata Labels
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: modelData.name
                                font.family: "Outfit, Inter, sans-serif"
                                font.pixelSize: 14
                                font.bold: true
                                color: isSelected ? Theme.primary : Theme.foreground
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.comment || modelData.genericName || ""
                                font.family: "Outfit, Inter, sans-serif"
                                font.pixelSize: 11
                                color: Theme.foregroundMuted
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                    }
                }

                // Mouse click to launch
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: launcherRoot.selectedIndex = index
                    onClicked: {
                        modelData.execute();
                        root.launcherVisible = false;
                    }
                }
            }
        }
    }
}
