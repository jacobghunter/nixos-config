pragma Singleton
import QtQuick
import qs.lib as GlobalTheme

QtObject {
    // Note: QML hex colors require "0x" and an ARGB or RGB format.
    // We combine your alpha values directly with the base colors for clarity.

    // Base Colors (dynamically pulled from the global tinty theme)
    readonly property color primary: GlobalTheme.Theme.primary
    readonly property color secondary: GlobalTheme.Theme.secondary
    readonly property color special: GlobalTheme.Theme.accent
    readonly property color inactive: GlobalTheme.Theme.comment
    readonly property color background: GlobalTheme.Theme.background
    readonly property color text: GlobalTheme.Theme.foreground

    // Translucent UI Elements (Alpha mixed in)
    // Hex order is #AARRGGBB (Alpha, Red, Green, Blue)
    readonly property color crust: Qt.rgba(GlobalTheme.Theme.backgroundAlt.r, GlobalTheme.Theme.backgroundAlt.g, GlobalTheme.Theme.backgroundAlt.b, 0.85) // Your bar's current color
    readonly property color panelBackground: Qt.rgba(GlobalTheme.Theme.background.r, GlobalTheme.Theme.background.g, GlobalTheme.Theme.background.b, 0.8) // background + alpha (cc)
    readonly property color surfaceDark: Qt.rgba(GlobalTheme.Theme.backgroundDark.r, GlobalTheme.Theme.backgroundDark.g, GlobalTheme.Theme.backgroundDark.b, 0.93) // waybar-dark + alpha-waybar (ee)
    readonly property color surfaceTrough: GlobalTheme.Theme.selectionBackground
    readonly property color shadow: GlobalTheme.Theme.backgroundDarkest ?? "#1a1a1a"

    // Borders and Layouts
    readonly property int borderSize: 1
    readonly property int borderRadius: 8
    readonly property color borderColor: Qt.rgba(GlobalTheme.Theme.foreground.r, GlobalTheme.Theme.foreground.g, GlobalTheme.Theme.foreground.b, 0.15)
}
