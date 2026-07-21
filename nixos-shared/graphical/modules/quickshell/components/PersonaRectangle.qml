pragma ComponentBehavior: Bound

import QtQuick
import "../services"

Item {
    id: root

    // --- Public API ---
    // Default property allows standard QML child declarations to automatically 
    // go inside the stable content area.
    default property alias contentData: contentArea.data

    // 1. Primary (Front) Border & Styling Properties
    property color borderColor: "#ffffff"
    property real borderWidth: 3.0
    property color backgroundColor: "transparent"

    // 2. Secondary (Back) Border Properties
    property bool showBackBorder: true
    property color backBorderColor: "#ff0000"      // Persona Red
    property real backBorderWidth: 3.0
    property real backBorderOffsetX: 4.0            // Static X displacement to make the back border stick out
    property real backBorderOffsetY: 4.0            // Static Y displacement to make the back border stick out

    // 3. Jitter & Animation Control
    property real maxShift: 3.0                     // Maximum random jitter range (pixels)
    property real updateInterval: 200               // How often the shape updates (250ms = 0.25s)
    property real animationDuration: 350            //Snappy transition duration between states
    property bool active: true                      // Toggle animation on/off
    property real contentPadding: 0                 // Custom margin/padding inside the stable area

    // --- Dynamic Safety Margin to prevent any clipping ---
    readonly property real safetyInset: root.maxShift + 
                                         Math.max(root.borderWidth, root.backBorderWidth) + 
                                         Math.max(Math.abs(root.backBorderOffsetX), Math.abs(root.backBorderOffsetY)) + 
                                         2.0

    // --- Internal Properties: Front Border Coordinates ---
    property real tlX: targetTlX
    property real tlY: targetTlY
    property real trX: targetTrX
    property real trY: targetTrY
    property real brX: targetBrX
    property real brY: targetBrY
    property real blX: targetBlX
    property real blY: targetBlY

    // Target offsets for the front border
    property real targetTlX: 0
    property real targetTlY: 0
    property real targetTrX: 0
    property real targetTrY: 0
    property real targetBrX: 0
    property real targetBrY: 0
    property real targetBlX: 0
    property real targetBlY: 0

    // --- Internal Properties: Back Border Coordinates ---
    property real backTlX: targetBackTlX
    property real backTlY: targetBackTlY
    property real backTrX: targetBackTrX
    property real backTrY: targetBackTrY
    property real backBrX: targetBackBrX
    property real backBrY: targetBackBrY
    property real backBlX: targetBackBlX
    property real backBlY: targetBackBlY

    // Target offsets for the back border
    property real targetBackTlX: 0
    property real targetBackTlY: 0
    property real targetBackTrX: 0
    property real targetBackTrY: 0
    property real targetBackBrX: 0
    property real targetBackBrY: 0
    property real targetBackBlX: 0
    property real targetBackBlY: 0

    // --- Smooth animations (snappy OutCubic easing) ---
    // Front Border Behaviors
    Behavior on tlX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on tlY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on trX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on trY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on brX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on brY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on blX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on blY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }

    // Back Border Behaviors
    Behavior on backTlX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on backTlY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on backTrX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on backTrY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on backBrX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on backBrY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on backBlX { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
    Behavior on backBlY { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }

    // --- Paint Trigger Hookups ---
    // Repaint front border updates
    onTlXChanged: canvas.requestPaint()
    onTlYChanged: canvas.requestPaint()
    onTrXChanged: canvas.requestPaint()
    onTrYChanged: canvas.requestPaint()
    onBrXChanged: canvas.requestPaint()
    onBrYChanged: canvas.requestPaint()
    onBlXChanged: canvas.requestPaint()
    onBlYChanged: canvas.requestPaint()

    // Repaint back border updates
    onBackTlXChanged: canvas.requestPaint()
    onBackTlYChanged: canvas.requestPaint()
    onBackTrXChanged: canvas.requestPaint()
    onBackTrYChanged: canvas.requestPaint()
    onBackBrXChanged: canvas.requestPaint()
    onBackBrYChanged: canvas.requestPaint()
    onBackBlXChanged: canvas.requestPaint()
    onBackBlYChanged: canvas.requestPaint()

    // Timer to update targets (keeping front and back updates out of sync)
    Timer {
        id: jitterTimer
        interval: root.updateInterval
        running: root.active
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            // Front border targets
            root.targetTlX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetTlY = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetTrX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetTrY = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBrX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBrY = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBlX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBlY = (Math.random() * 2.0 - 1.0) * root.maxShift;

            // Back border targets (randomized independently, hence out of sync)
            root.targetBackTlX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBackTlY = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBackTrX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBackTrY = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBackBrX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBackBrY = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBackBlX = (Math.random() * 2.0 - 1.0) * root.maxShift;
            root.targetBackBlY = (Math.random() * 2.0 - 1.0) * root.maxShift;
        }

        onRunningChanged: {
            if (!running) {
                // Return to neutral state if stopped
                root.targetTlX = 0; root.targetTlY = 0;
                root.targetTrX = 0; root.targetTrY = 0;
                root.targetBrX = 0; root.targetBrY = 0;
                root.targetBlX = 0; root.targetBlY = 0;

                root.targetBackTlX = 0; root.targetBackTlY = 0;
                root.targetBackTrX = 0; root.targetBackTrY = 0;
                root.targetBackBrX = 0; root.targetBackBrY = 0;
                root.targetBackBlX = 0; root.targetBackBlY = 0;
            }
        }
    }

    // Canvas to draw both dynamic border layers
    Canvas {
        id: canvas
        
        anchors.fill: parent

        // Repaint when properties change
        property var redrawTrigger: [
            root.tlX, root.tlY, root.trX, root.trY,
            root.brX, root.brY, root.blX, root.blY,
            root.backTlX, root.backTlY, root.backTrX, root.backTrY,
            root.backBrX, root.backBrY, root.backBlX, root.backBlY,
            root.width, root.height, 
            root.borderColor, root.backgroundColor, root.borderWidth,
            root.backBorderColor, root.backBorderWidth, root.backBorderOffsetX, root.backBorderOffsetY, root.showBackBorder
        ]

        onRedrawTriggerChanged: canvas.requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var inset = root.safetyInset;

            // --- 1. Draw Back Border (if visible) ---
            if (root.showBackBorder && root.backBorderWidth > 0 && root.backBorderColor !== "transparent" && root.backBorderColor !== "#00000000") {
                // The base corners for the back border are offset by backBorderOffsetX and backBorderOffsetY
                var bx0 = inset + root.backBorderOffsetX;
                var by0 = inset + root.backBorderOffsetY;
                var bx1 = root.width - inset + root.backBorderOffsetX;
                var by1 = root.height - inset + root.backBorderOffsetY;

                var bpTLx = bx0 + root.backTlX;
                var bpTLy = by0 + root.backTlY;
                
                var bpTRx = bx1 + root.backTrX;
                var bpTRy = by0 + root.backTrY;
                
                var bpBRx = bx1 + root.backBrX;
                var bpBRy = by1 + root.backBrY;
                
                var bpBLx = bx0 + root.backBlX;
                var bpBLy = by1 + root.backBlY;

                ctx.beginPath();
                ctx.moveTo(bpTLx, bpTLy);
                ctx.lineTo(bpTRx, bpTRy);
                ctx.lineTo(bpBRx, bpBRy);
                ctx.lineTo(bpBLx, bpBLy);
                ctx.closePath();

                // Fill the back rectangle completely to prevent background bleed-through
                ctx.fillStyle = root.backBorderColor;
                ctx.fill();

                // Stroke the back border outline
                if (root.backBorderWidth > 0) {
                    ctx.lineWidth = root.backBorderWidth;
                    ctx.strokeStyle = root.backBorderColor;
                    ctx.stroke();
                }
            }

            // --- 2. Draw Front Rectangle (Background & Main Border) ---
            var x0 = inset;
            var y0 = inset;
            var x1 = root.width - inset;
            var y1 = root.height - inset;

            var pTLx = x0 + root.tlX;
            var pTLy = y0 + root.tlY;
            
            var pTRx = x1 + root.trX;
            var pTRy = y0 + root.trY;
            
            var pBRx = x1 + root.brX;
            var pBRy = y1 + root.brY;
            
            var pBLx = x0 + root.blX;
            var pBLy = y1 + root.blY;

            ctx.beginPath();
            ctx.moveTo(pTLx, pTLy);
            ctx.lineTo(pTRx, pTRy);
            ctx.lineTo(pBRx, pBRy);
            ctx.lineTo(pBLx, pBLy);
            ctx.closePath();

            // Mask/Erase the front shape's interior from the back border,
            // so the back border line doesn't show through semi-transparent backgrounds.
            if (root.showBackBorder) {
                ctx.globalCompositeOperation = "destination-out";
                ctx.fillStyle = "#ffffff"; // Color value is ignored in destination-out
                ctx.fill();
                ctx.globalCompositeOperation = "source-over"; // Restore default blending
            }

            // Paint the foreground background fill
            if (root.backgroundColor !== "transparent" && root.backgroundColor !== "#00000000") {
                ctx.fillStyle = root.backgroundColor;
                ctx.fill();
            }

            // Stroke the foreground border
            if (root.borderWidth > 0 && root.borderColor !== "transparent" && root.borderColor !== "#00000000") {
                ctx.lineWidth = root.borderWidth;
                ctx.strokeStyle = root.borderColor;
                ctx.stroke();
            }
        }
    }

    // Stable content container where children are placed
    Item {
        id: contentArea
        anchors.fill: parent
        // Inset by the safety margins to avoid overlapping the dynamic borders
        anchors.margins: root.safetyInset + root.contentPadding
    }
}
