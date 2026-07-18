#!/usr/bin/env bash
set -euo pipefail

out="$HOME/.config/quickshell/lib/Colors.qml"
mkdir -p "$(dirname "$out")"

{
  echo "pragma Singleton"
  echo "import Quickshell"
  echo "import QtQuick"
  echo ""
  echo "Singleton {"
  echo "    readonly property string schemeId: \"${TINTY_SCHEME_ID:-}\""
  echo "    readonly property string schemeVariant: \"${TINTY_SCHEME_VARIANT:-}\""
  echo ""

  # base00-base0F (base16) + base10-base17 (base24 extension)
  for slot in 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17; do
    r_var="TINTY_SCHEME_PALETTE_BASE${slot}_HEX_R"
    g_var="TINTY_SCHEME_PALETTE_BASE${slot}_HEX_G"
    b_var="TINTY_SCHEME_PALETTE_BASE${slot}_HEX_B"
    r_val="${!r_var:-}"
    g_val="${!g_var:-}"
    b_val="${!b_var:-}"

    if [ -n "$r_val" ] && [ -n "$g_val" ] && [ -n "$b_val" ]; then
      slot_lower=$(echo "$slot" | tr '[:upper:]' '[:lower:]')
      echo "    readonly property color base${slot_lower}: \"#${r_val}${g_val}${b_val}\""
    fi
  done

  echo "}"
} >"$out" >"$out"
