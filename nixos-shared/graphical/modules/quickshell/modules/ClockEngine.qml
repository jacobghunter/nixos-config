import QtQuick

Item {
    id: engine
    property string timeString: ""

    Timer {
        id: internalTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: engine.timeString = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss AP")
        Component.onCompleted: engine.timeString = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss AP")
    }
}
