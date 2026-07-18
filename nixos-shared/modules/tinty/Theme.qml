pragma Singleton
import Quickshell
import QtQuick


// Semantic color aliases on top of the standard base16/base24 slots in
// Colors.qml. This file is static and hand-written — it never needs to be
// regenerated when the active scheme changes, since every property here is
// a live binding to Colors.* rather than a hardcoded value. Only edit this
// file if you want to change what a role *means* (e.g. remap `primary` to
// a different slot); the actual color values always come from Colors.qml.

Singleton {
    // Backgrounds
    readonly property color background: Colors.base00
    readonly property color backgroundAlt: Colors.base01
    readonly property color backgroundDark: Colors.base10 ?? Colors.base00
    readonly property color backgroundDarkest: Colors.base11 ?? Colors.base00
    readonly property color selectionBackground: Colors.base02

    // Foregrounds
    readonly property color foreground: Colors.base05
    readonly property color foregroundMuted: Colors.base04
    readonly property color foregroundBright: Colors.base06
    readonly property color foregroundBrightest: Colors.base07
    readonly property color comment: Colors.base03

    // Semantic accents (base16 core, always present)
    readonly property color error: Colors.base08
    readonly property color warning: Colors.base09
    readonly property color accent: Colors.base0A
    readonly property color success: Colors.base0B
    readonly property color info: Colors.base0C
    readonly property color primary: Colors.base0D
    readonly property color secondary: Colors.base0E
    readonly property color deprecated: Colors.base0F

    // Bright ANSI variants (base24 only — fall back to the non-bright
    // version if the active scheme is base16, since those slots won't exist)
    readonly property color errorBright: Colors.base12 ?? Colors.base08
    readonly property color warningBright: Colors.base13 ?? Colors.base0A
    readonly property color successBright: Colors.base14 ?? Colors.base0B
    readonly property color infoBright: Colors.base15 ?? Colors.base0C
    readonly property color primaryBright: Colors.base16 ?? Colors.base0D
    readonly property color secondaryBright: Colors.base17 ?? Colors.base0E
}
