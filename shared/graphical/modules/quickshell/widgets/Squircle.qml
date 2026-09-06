import QtQuick
import QtQuick.Shapes
import "SquircleHelper.js" as SquircleHelper

Item {
    id: root
    anchors.fill: parent

    property color color: "transparent"
    property int radius: 12
    property int roundingPower: 4

    property SquircleBorder border: SquircleBorder {}

    // Dynamically maps Hyprland's superellipse power to Bezier tension
    readonly property real squircleTension: SquircleHelper.getTension(roundingPower)

    readonly property real inset: border.width / 2
    readonly property real w: width - inset
    readonly property real h: height - inset
    readonly property real offset: radius * squircleTension

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: root.border.color
            strokeWidth: root.border.width

            startX: root.inset + root.radius; startY: root.inset

            PathLine { x: root.w - root.radius; y: root.inset }
            
            PathCubic {
                x: root.w; y: root.inset + root.radius
                control1X: root.w - root.radius + root.offset; control1Y: root.inset
                control2X: root.w; control2Y: root.inset + root.radius - root.offset
            }
            
            PathLine { x: root.w; y: root.h - root.radius }
            
            PathCubic {
                x: root.w - root.radius; y: root.h
                control1X: root.w; control1Y: root.h - root.radius + root.offset
                control2X: root.w - root.radius + root.offset; control2Y: root.h
            }
            
            PathLine { x: root.inset + root.radius; y: root.h }
            
            PathCubic {
                x: root.inset; y: root.h - root.radius
                control1X: root.inset + root.radius - root.offset; control1Y: root.h
                control2X: root.inset; control2Y: root.h - root.radius + root.offset
            }
            
            PathLine { x: root.inset; y: root.inset + root.radius }
            
            PathCubic {
                x: root.inset + root.radius; y: root.inset
                control1X: root.inset; control1Y: root.inset + root.radius - root.offset
                control2X: root.inset + root.radius - root.offset; control2Y: root.inset
            }
        }
    }
}
