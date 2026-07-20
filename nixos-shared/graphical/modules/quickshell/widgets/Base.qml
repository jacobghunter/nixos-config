import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color bgColor: Qt.alpha(Theme.background, 0.5)
    property color borderColor: Qt.alpha(Theme.backgroundAlt, 0.8)
    property int padding: 12
    property int borderWidth: 2
    property int radius: 24
    
    // 0.55228 = Perfect circle (standard rounded corner)
    // 0.75 to 0.85 = Apple-style continuous squircle
    // 1.0 = Sharp parabolic corner (the bug you were seeing)
    property real squircleTension: 0.8

    readonly property real inset: borderWidth / 2
    readonly property real w: width - inset
    readonly property real h: height - inset
    
    // This dynamically calculates how far the control points should be 
    // pushed towards the corner based on your radius.
    readonly property real offset: radius * squircleTension

    default property alias content: contentContainer.data

    Shape {
        anchors.fill: parent
        
        layer.enabled: true
        layer.samples: 4 

        ShapePath {
            fillColor: root.bgColor
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth

            // Start at top-left, properly accounting for the inset
            startX: root.inset + root.radius; startY: root.inset

            // Top edge
            PathLine { x: root.w - root.radius; y: root.inset }
            
            // Top-right squircle corner
            PathCubic {
                x: root.w; y: root.inset + root.radius
                control1X: root.w - root.radius + root.offset; control1Y: root.inset
                control2X: root.w; control2Y: root.inset + root.radius - root.offset
            }
            
            // Right edge
            PathLine { x: root.w; y: root.h - root.radius }
            
            // Bottom-right squircle corner
            PathCubic {
                x: root.w - root.radius; y: root.h
                control1X: root.w; control1Y: root.h - root.radius + root.offset
                control2X: root.w - root.radius + root.offset; control2Y: root.h
            }
            
            // Bottom edge
            PathLine { x: root.inset + root.radius; y: root.h }
            
            // Bottom-left squircle corner
            PathCubic {
                x: root.inset; y: root.h - root.radius
                control1X: root.inset + root.radius - root.offset; control1Y: root.h
                control2X: root.inset; control2Y: root.h - root.radius + root.offset
            }
            
            // Left edge
            PathLine { x: root.inset; y: root.inset + root.radius }
            
            // Top-left squircle corner
            PathCubic {
                x: root.inset + root.radius; y: root.inset
                control1X: root.inset; control1Y: root.inset + root.radius - root.offset
                control2X: root.inset + root.radius - root.offset; control2Y: root.inset
            }
        }
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
