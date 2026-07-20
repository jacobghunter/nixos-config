import QtQuick
import "../services"

Item {
    id: root
    
    property color bgColor: Theme.baseBackground 
    property color borderColor: Theme.baseBorder
    
    property int padding: 12
    property int borderWidth: 1
    property int radius: 24
    property int roundingPower: 4

    default property alias content: contentContainer.data

    Squircle {
        color: root.bgColor
        borderColor: root.borderColor
        borderWidth: root.borderWidth
        radius: root.radius
        roundingPower: root.roundingPower
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
