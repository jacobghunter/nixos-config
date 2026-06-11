#!/usr/bin/env bash

WAYLE_DIR="$HOME/.config/wayle"
CONFIG_FILE="$WAYLE_DIR/config.toml"
RUNTIME_FILE="$WAYLE_DIR/runtime.toml"

# 1. Unlink config.toml to make it writable
if [ -L "$CONFIG_FILE" ]; then
    echo "-> Unlinking config.toml and replacing with a writable copy..."
    TARGET=$(readlink -f "$CONFIG_FILE")
    rm -f "$CONFIG_FILE"
    cp "$TARGET" "$CONFIG_FILE"
    chmod u+w "$CONFIG_FILE"
else
    echo "-> config.toml is already writable."
fi

# 2. Open the GUI
echo "-> Opening wayle-settings GUI... Make your changes, then CLOSE the GUI window to continue."
wayle-settings

# 3. Read and convert to Nix format
echo "-> Converting TOML configuration to Nix format..."
if [ -d "$WAYLE_DIR" ]; then
    cd "$WAYLE_DIR" || exit 1
    if [ -f "runtime.toml" ]; then
        NIX_CONFIG=$(nix-instantiate --eval --expr '(builtins.fromTOML (builtins.readFile ./config.toml)) // (builtins.fromTOML (builtins.readFile ./runtime.toml))' 2>/dev/null | nixfmt -)
    else
        NIX_CONFIG=$(nix-instantiate --eval --expr 'builtins.fromTOML (builtins.readFile ./config.toml)' 2>/dev/null | nixfmt -)
    fi
    cd - >/dev/null || exit 1
fi

echo ""
echo "=================================================="
echo " Copy the block below into your wayle.nix settings"
echo "=================================================="
echo "$NIX_CONFIG"
echo "=================================================="
echo ""
echo "-> After pasting the configuration, run 'rebuild' to apply and lock it back to the Nix store."
