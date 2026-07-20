import QtQuick
import QtQuick.Shapes

Item {
    id: root
    anchors.fill: parent

    property color color: "transparent"
    property color borderColor: "transparent"
    property int borderWidth: 0
    property int radius: 12
    property int roundingPower: 4

    // Dynamically maps Hyprland's superellipse power to Bezier tension
    readonly property real squircleTension: {
        switch (roundingPower) {
            case 2: return 0.552; // Standard circle
            case 3: return 0.783; // Smooth corner
            case 4: return 0.909; // True squircle
            case 5: return 0.950; // Sharp squircle
            case 6: return 0.970; 
            case 7: return 0.982; 
            case 8: return 0.990; 
            case 9: return 0.995; 
            case 10: return 0.998; 
            default: return 0.552; 
        }
    }

    readonly property real inset: borderWidth / 2
    readonly property real w: width - inset
    readonly property real h: height - inset
    readonly property real offset: radius * squircleTension

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth

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
