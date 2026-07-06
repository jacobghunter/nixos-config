pragma Singleton
import QtQuick

QtObject {
    // Note: QML hex colors require "0x" and an ARGB or RGB format.
    // We combine your alpha values directly with the base colors for clarity.

    // Base Colors (Fully Opaque)
    readonly property color primary: "#ce00ff"
    readonly property color secondary: "#00dbff"
    readonly property color special: "#fb42b6"
    readonly property color inactive: "#595959"
    readonly property color background: "#000000"
    readonly property color text: "#cdd6f4"

    // Translucent UI Elements (Alpha mixed in)
    // Hex order is #AARRGGBB (Alpha, Red, Green, Blue)
    readonly property color crust: "#d911111b" // Your bar's current color
    readonly property color panelBackground: "#cc000000" // background + alpha (cc)
    readonly property color surfaceDark: "#ee11111b" // waybar-dark + alpha-waybar (ee)
    readonly property color surfaceTrough: "#313244"
    readonly property color shadow: "#1a1a1a"

    // Borders and Layouts
    readonly property int borderSize: 1
    readonly property int borderRadius: 10
    readonly property color borderColor: "#26cdd6f4"
}
