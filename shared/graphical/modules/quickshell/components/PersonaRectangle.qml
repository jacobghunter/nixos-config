pragma ComponentBehavior: Bound

import QtQuick
import "../services"
import "../widgets/SquircleHelper.js" as SquircleHelper

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

    // Double Border (Outer Outline) Properties
    property bool showDoubleBorder: false              // Toggle to draw a second parallel outline around the front border
    property color doubleBorderColor: borderColor     // Color of the second outline (defaults to borderColor)
    property real doubleBorderWidth: 1.0              // Width of the second outline in pixels
    property real doubleBorderOffset: 3.0             // Distance in pixels outside the main front border

    // 2. Secondary (Back) Border Properties
    property bool showBackBorder: true
    property color backBorderColor: "transparent"   // Color of the back border outline stroke
    property color backBackgroundColor: "transparent" // Color of the back background fill
    property real backBorderWidth: 3.0
    property real backBorderOffsetX: 4.0            // Static X displacement to make the back border stick out
    property real backBorderOffsetY: 4.0            // Static Y displacement to make the back border stick out
    property real backBorderExpansion: 0.0          // Pixels by which the back rectangle is expanded on all sides

    // 3. Squircle/Rounding Settings
    property int roundingPower: 0                   // Front superellipse power: 0 = square, 2 = circle, 4 = squircle
    property real radius: 12.0                      // Front corner radius (used if roundingPower > 0)
    property int backRoundingPower: roundingPower   // Back superellipse power (defaults to front power)
    property real backRadius: radius                // Back corner radius (defaults to front radius)

    // 4. Jitter & Animation Control
    property real maxShift: 6.0                     // Maximum random jitter range (pixels)
    property real updateInterval: 250               // How often the shape updates (250ms = 0.25s)
    property real animationDuration: 180            // Snappy transition duration between states
    property bool active: true                      // Toggle animation on/off
    property real contentPadding: 0                 // Custom margin/padding inside the stable area

    // Emitted every time new jitter targets are rolled, so content can sync its own
    // motion/flashes to the same beat as the border instead of animating on its own clock.
    signal jittered()

    // --- Dynamic Insets to prevent clipping while allowing expansion ---
    // Stable inset for the front shape and internal content area (keeps them constant size)
    readonly property real frontInset: root.maxShift + 
                                        root.borderWidth + 
                                        (root.showDoubleBorder ? Math.max(0.0, root.doubleBorderOffset) : 0.0) + 
                                        2.0

    // Safety margin to prevent any drawing from clipping at the parent canvas boundaries.
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

            root.jittered();
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
            root.backBorderColor, root.backBackgroundColor, root.backBorderWidth, root.backBorderOffsetX, root.backBorderOffsetY, root.showBackBorder,
            root.roundingPower, root.radius,
            root.backRoundingPower, root.backRadius,
            root.backBorderExpansion,
            root.showDoubleBorder, root.doubleBorderColor, root.doubleBorderWidth, root.doubleBorderOffset
        ]

        onRedrawTriggerChanged: canvas.requestPaint()


        // Helper to generate a squircle path with Bezier corners that adapt to shifted coordinates
        function makeSquirclePath(ctx, cTL, cTR, cBR, cBL, r, o) {
            if (r <= 0.0) {
                // Base Case: 0 radius, draw a simple quadrilateral
                ctx.moveTo(cTL.x, cTL.y);
                ctx.lineTo(cTR.x, cTR.y);
                ctx.lineTo(cBR.x, cBR.y);
                ctx.lineTo(cBL.x, cBL.y);
                ctx.closePath();
                return;
            }

            // Compute side vectors between shifting corners
            var tx = cTR.x - cTL.x, ty = cTR.y - cTL.y;
            var rx = cBR.x - cTR.x, ry = cBR.y - cTR.y;
            var bx = cBL.x - cBR.x, by = cBL.y - cBR.y;
            var lx = cTL.x - cBL.x, ly = cTL.y - cBL.y;

            // Vector lengths
            var lt = Math.max(1, Math.sqrt(tx * tx + ty * ty));
            var lr = Math.max(1, Math.sqrt(rx * rx + ry * ry));
            var lb = Math.max(1, Math.sqrt(bx * bx + by * by));
            var ll = Math.max(1, Math.sqrt(lx * lx + ly * ly));

            // Unit direction vectors along the edges
            var ut = { x: tx / lt, y: ty / lt };
            var ur = { x: rx / lr, y: ry / lr };
            var ub = { x: bx / lb, y: by / lb };
            var ul = { x: lx / ll, y: ly / ll };

            // Start & end points of corner Bezier arcs
            var pTL_L = { x: cTL.x - ul.x * r, y: cTL.y - ul.y * r };
            var pTL_T = { x: cTL.x + ut.x * r, y: cTL.y + ut.y * r };
            var pTR_T = { x: cTR.x - ut.x * r, y: cTR.y - ut.y * r };
            var pTR_R = { x: cTR.x + ur.x * r, y: cTR.y + ur.y * r };
            var pBR_R = { x: cBR.x - ur.x * r, y: cBR.y - ur.y * r };
            var pBR_B = { x: cBR.x + ub.x * r, y: cBR.y + ub.y * r };
            var pBL_B = { x: cBL.x - ub.x * r, y: cBL.y - ub.y * r };
            var pBL_L = { x: cBL.x + ul.x * r, y: cBL.y + ul.y * r };

            // Control points for the corner Beziers, pulling from the edge start/end points towards the corners
            // The distance of the control point from the corner along the edge is (r - o)
            var d = r - o;
            var cpTL_1 = { x: cTL.x - ul.x * d, y: cTL.y - ul.y * d };
            var cpTL_2 = { x: cTL.x + ut.x * d, y: cTL.y + ut.y * d };
            var cpTR_1 = { x: cTR.x - ut.x * d, y: cTR.y - ut.y * d };
            var cpTR_2 = { x: cTR.x + ur.x * d, y: cTR.y + ur.y * d };
            var cpBR_1 = { x: cBR.x - ur.x * d, y: cBR.y - ur.y * d };
            var cpBR_2 = { x: cBR.x + ub.x * d, y: cBR.y + ub.y * d };
            var cpBL_1 = { x: cBL.x - ub.x * d, y: cBL.y - ub.y * d };
            var cpBL_2 = { x: cBL.x + ul.x * d, y: cBL.y + ul.y * d };

            // Trace path
            ctx.moveTo(pTL_T.x, pTL_T.y);
            ctx.lineTo(pTR_T.x, pTR_T.y);
            ctx.bezierCurveTo(cpTR_1.x, cpTR_1.y, cpTR_2.x, cpTR_2.y, pTR_R.x, pTR_R.y);
            ctx.lineTo(pBR_R.x, pBR_R.y);
            ctx.bezierCurveTo(cpBR_1.x, cpBR_1.y, cpBR_2.x, cpBR_2.y, pBR_B.x, pBR_B.y);
            ctx.lineTo(pBL_B.x, pBL_B.y);
            ctx.bezierCurveTo(cpBL_1.x, cpBL_1.y, cpBL_2.x, cpBL_2.y, pBL_L.x, pBL_L.y);
            ctx.lineTo(pTL_L.x, pTL_L.y);
            ctx.bezierCurveTo(cpTL_1.x, cpTL_1.y, cpTL_2.x, cpTL_2.y, pTL_T.x, pTL_T.y);
            ctx.closePath();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            // Compute front superellipse parameters
            var effFrontRadius = (root.roundingPower > 0) ? root.radius : 0.0;
            var frontTension = SquircleHelper.getTension(root.roundingPower);
            var frontOffset = effFrontRadius * frontTension;

            // Compute back superellipse parameters
            var effBackRadius = (root.backRoundingPower > 0) ? root.backRadius : 0.0;
            var backTension = SquircleHelper.getTension(root.backRoundingPower);
            var backOffset = effBackRadius * backTension;

            // Determine border alpha based on background color transparency
            var isBgTransparent = (root.backgroundColor === "transparent" || root.backgroundColor.a === 0.0);
            var borderAlpha = isBgTransparent ? 1.0 : root.backgroundColor.a;

            // --- 1. Draw Back Rectangle (Filled) ---
            if (root.showBackBorder) {
                // Resolve actual back colors with mutual inheritance (defaults to #ff0000)
                var hasBackBorder = (root.backBorderColor !== "transparent" && root.backBorderColor !== "#00000000" && root.backBorderColor.a !== 0.0);
                var hasBackBg = (root.backBackgroundColor !== "transparent" && root.backBackgroundColor !== "#00000000" && root.backBackgroundColor.a !== 0.0);

                var resolvedBackBorderColor = "#ff0000";
                var resolvedBackBgColor = "#ff0000";

                if (hasBackBorder && hasBackBg) {
                    resolvedBackBorderColor = root.backBorderColor;
                    resolvedBackBgColor = root.backBackgroundColor;
                } else if (hasBackBorder) {
                    resolvedBackBorderColor = root.backBorderColor;
                    resolvedBackBgColor = root.backBorderColor;
                } else if (hasBackBg) {
                    resolvedBackBorderColor = root.backBackgroundColor;
                    resolvedBackBgColor = root.backBackgroundColor;
                }

                // Only draw if at least one resolved color is non-transparent/visible
                if (resolvedBackBgColor !== "transparent" || (root.backBorderWidth > 0 && resolvedBackBorderColor !== "transparent")) {
                    // The back border baseline is offset outwards by backBorderExpansion
                    var backInset = root.frontInset - root.backBorderExpansion;
                    var bx0 = backInset + root.backBorderOffsetX;
                    var by0 = backInset + root.backBorderOffsetY;
                    var bx1 = root.width - backInset + root.backBorderOffsetX;
                    var by1 = root.height - backInset + root.backBorderOffsetY;

                    var cBackTL = { x: bx0 + root.backTlX, y: by0 + root.backTlY };
                    var cBackTR = { x: bx1 + root.backTrX, y: by0 + root.backTrY };
                    var cBackBR = { x: bx1 + root.backBrX, y: by1 + root.backBrY };
                    var cBackBL = { x: bx0 + root.backBlX, y: by1 + root.backBlY };

                    ctx.beginPath();
                    makeSquirclePath(ctx, cBackTL, cBackTR, cBackBR, cBackBL, effBackRadius, backOffset);

                    // Solid fill (keeps background color opaque)
                    if (resolvedBackBgColor !== "transparent" && resolvedBackBgColor !== "#00000000") {
                        ctx.globalAlpha = 1.0;
                        ctx.fillStyle = resolvedBackBgColor;
                        ctx.fill();
                    }

                    // Stroke outline (optional - matches translucent borderAlpha)
                    if (root.backBorderWidth > 0 && resolvedBackBorderColor !== "transparent" && resolvedBackBorderColor !== "#00000000") {
                        ctx.globalAlpha = borderAlpha;
                        ctx.lineWidth = root.backBorderWidth;
                        ctx.strokeStyle = resolvedBackBorderColor;
                        ctx.stroke();
                        ctx.globalAlpha = 1.0;
                    }
                }
            }

            // --- 2. Draw Front Rectangle (Background & Main Border) ---
            // The front border baseline is kept completely constant to prevent content shrinking
            var x0 = root.frontInset;
            var y0 = root.frontInset;
            var x1 = root.width - root.frontInset;
            var y1 = root.height - root.frontInset;

            var cTL = { x: x0 + root.tlX, y: y0 + root.tlY };
            var cTR = { x: x1 + root.trX, y: y0 + root.trY };
            var cBR = { x: x1 + root.brX, y: y1 + root.brY };
            var cBL = { x: x0 + root.blX, y: y1 + root.blY };

            // Setup path for front shape
            ctx.beginPath();
            makeSquirclePath(ctx, cTL, cTR, cBR, cBL, effFrontRadius, frontOffset);

            // Erase front footprint from back layer to support translucent backgrounds (must be fully opaque mask)
            if (root.showBackBorder) {
                ctx.globalAlpha = 1.0;
                ctx.globalCompositeOperation = "destination-out";
                ctx.fillStyle = "#ffffff"; // Color is ignored in destination-out
                ctx.fill();
                ctx.globalCompositeOperation = "source-over"; // Restore default
            }

            // Fill front background (at full alpha so its native transparency matches)
            if (root.backgroundColor !== "transparent" && root.backgroundColor !== "#00000000") {
                ctx.fillStyle = root.backgroundColor;
                ctx.fill();
            }

            // Stroke front border (using matched background alpha)
            if (root.borderWidth > 0 && root.borderColor !== "transparent" && root.borderColor !== "#00000000") {
                ctx.globalAlpha = borderAlpha;
                ctx.lineWidth = root.borderWidth;
                ctx.strokeStyle = root.borderColor;
                ctx.stroke();
                ctx.globalAlpha = 1.0; // Reset
            }

            // --- 3. Draw Double Border (Outer Front Outline, if enabled) ---
            if (root.showDoubleBorder && root.doubleBorderWidth > 0 && root.doubleBorderColor !== "transparent" && root.doubleBorderColor !== "#00000000") {
                var outerInset = root.frontInset - root.doubleBorderOffset;
                var ox0 = outerInset;
                var oy0 = outerInset;
                var ox1 = root.width - outerInset;
                var oy1 = root.height - outerInset;

                var cOuterTL = { x: ox0 + root.tlX, y: oy0 + root.tlY };
                var cOuterTR = { x: ox1 + root.trX, y: oy0 + root.trY };
                var cOuterBR = { x: ox1 + root.brX, y: oy1 + root.brY };
                var cOuterBL = { x: ox0 + root.blX, y: oy1 + root.blY };

                var effOuterRadius = (root.roundingPower > 0) ? (root.radius + root.doubleBorderOffset) : 0.0;
                var outerOffset = effOuterRadius * frontTension;

                ctx.beginPath();
                makeSquirclePath(ctx, cOuterTL, cOuterTR, cOuterBR, cOuterBL, effOuterRadius, outerOffset);

                ctx.globalAlpha = borderAlpha;
                ctx.lineWidth = root.doubleBorderWidth;
                ctx.strokeStyle = root.doubleBorderColor;
                ctx.stroke();
                ctx.globalAlpha = 1.0; // Reset
            }
        }
    }

    // Stable content container where children are placed
    Item {
        id: contentArea
        anchors.fill: parent
        // Inset by the stable front margins to keep layout size constant
        anchors.margins: root.frontInset + root.contentPadding
    }
}
