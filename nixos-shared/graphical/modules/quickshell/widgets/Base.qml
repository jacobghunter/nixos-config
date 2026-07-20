import QtQuick
import QtQuick.Shapes
import "../services"

Item {
    id: root

    // RESTORED: Properties so you can apply Qt.alpha() from your widgets for blur
    property color bgColor: Theme.baseBackground 
    property color borderColor: Theme.baseBorder 
    
    property int padding: 12
    property int borderWidth: 2
    property int radius: 24
    
    // Match this to Hyprland's decoration:rounding_power (2 through 10)
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
            case 10: return 0.998; // Almost a completely sharp 90-degree box
            default: return 0.552; 
        }
    }

    readonly property real inset: borderWidth / 2
    readonly property real w: width - inset
    readonly property real h: height - inset
    
    readonly property real offset: radius * squircleTension

    default property alias content: contentContainer.data

    Shape {
        anchors.fill: parent
        
        layer.enabled: true
        layer.samples: 4 

        ShapePath {
            // RESTORED: Now this points to the properties, not the raw theme
            fillColor: root.bgColor
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

    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
