pragma Singleton
import Quickshell
import QtQuick
import qs.lib

QtObject {
    // From global Theme.qml
    readonly property color background: Theme.background
    readonly property color backgroundAlt: Theme.backgroundAlt
    readonly property color backgroundDark: Theme.backgroundDark
    readonly property color backgroundDarkest: Theme.backgroundDarkest
    readonly property color selectionBackground: Theme.selectionBackground

    // Foregrounds
    readonly property color foreground: Theme.foreground
    readonly property color foregroundMuted: Theme.foregroundMuted
    readonly property color foregroundBright: Theme.foregroundBright
    readonly property color foregroundBrightest: Theme.foregroundBrightest
    readonly property color comment: Theme.comment

    // Semantic accents 
    readonly property color error: Theme.error
    readonly property color warning: Theme.warning
    readonly property color accent: Theme.accent
    readonly property color success: Theme.success
    readonly property color info: Theme.info
    readonly property color primary: Theme.primary
    readonly property color secondary: Theme.secondary
    readonly property color deprecated: Theme.deprecated

    // Bright ANSI variants 
    readonly property color errorBright: Theme.errorBright
    readonly property color warningBright: Theme.warningBright
    readonly property color successBright: Theme.successBright
    readonly property color infoBright: Theme.infoBright
    readonly property color primaryBright: Theme.primaryBright
    readonly property color secondaryBright: Theme.secondaryBright

    // ==========================================
    // --- Custom UI Overrides & Layouts --------
    // ==========================================

    // Translucent UI Elements (Alpha mixed in)
    readonly property color crust: Qt.rgba(backgroundAlt.r, backgroundAlt.g, backgroundAlt.b, 0.85)
    readonly property color panelBackground: Qt.rgba(background.r, background.g, background.b, 0.8)
    readonly property color surfaceDark: Qt.rgba(backgroundDark.r, backgroundDark.g, backgroundDark.b, 0.93)
    readonly property color surfaceTrough: selectionBackground
    readonly property color shadow: backgroundDarkest ?? "#1a1a1a"

    // Borders and Layouts
    readonly property int borderSize: 1
    readonly property int borderRadius: 12
    readonly property color borderColor: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.15)
}
