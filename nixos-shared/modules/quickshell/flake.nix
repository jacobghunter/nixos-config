{
  description = "Quickshell development environment";
  # Inspo repos:
  # git clone https://github.com/ilyamiro/nixos-configuration.git
  # at /config/sessions/hyprland/scripts/quickshell
  # git clone https://github.com/caelestia-dots/shell.git
  # at /modules
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        runNested = pkgs.writeShellScriptBin "run-nested" ''
          set -euo pipefail

          PROJECT_DIR="$PWD"
          TEMPLATE="$PROJECT_DIR/nested.lua.template"
          GENERATED="$PROJECT_DIR/nested.generated.lua"

          if [ ! -f "$TEMPLATE" ]; then
            echo "Error: nested.lua.template not found in $PROJECT_DIR"
            echo "Run run-nested from your quickshell project directory."
            exit 1
          fi

          echo "Starting nested Hyprland with Quickshell..."

          sed \
            -e "s|QUICKSHELL_BIN|${pkgs.quickshell}/bin/quickshell|g" \
            -e "s|QML_PATH|$HOME/nixos-config/nixos-shared/modules/quickshell/shell.qml|g" \
            "$TEMPLATE" > "$GENERATED"

          env -u LD_LIBRARY_PATH -u QT_PLUGIN_PATH -u QML2_IMPORT_PATH \
            Hyprland -c "$GENERATED"
        '';

        serveDocs = pkgs.writeShellScriptBin "serve-docs" ''
          DOCS_DIR="$HOME/.cache/quickshell-docs"
          SITE_DIR="$DOCS_DIR/quickshell.org"

          if [ ! -d "$SITE_DIR" ]; then
            echo "No local copy found — mirroring Quickshell docs (needs network, one-time)..."
            mkdir -p "$DOCS_DIR"
            ${pkgs.wget}/bin/wget --mirror --convert-links --adjust-extension \
              --page-requisites --no-parent \
              --domains=quickshell.org \
              -P "$DOCS_DIR" \
              https://quickshell.org/docs/v0.3.0/
          fi

          echo "Serving Quickshell docs at http://localhost:8420"
          echo "(Ctrl+C to stop. Run 'update-docs' to refresh the mirror.)"
          ${pkgs.python3}/bin/python3 -m http.server 8420 --directory "$SITE_DIR"
        '';

        updateDocs = pkgs.writeShellScriptBin "update-docs" ''
          DOCS_DIR="$HOME/.cache/quickshell-docs"
          echo "Refreshing local Quickshell docs mirror (needs network)..."
          rm -rf "$DOCS_DIR"
          mkdir -p "$DOCS_DIR"
          ${pkgs.wget}/bin/wget --mirror --convert-links --adjust-extension \
            --page-requisites --no-parent -P "$DOCS_DIR" \
            https://quickshell.outfoxxed.me/
          echo "Done."
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            quickshell
            runNested
            serveDocs
            updateDocs
            wget
            python3
          ];
          shellHook = ''
            echo "=========================================================="
            echo "   Quickshell Development Shell (Offline-Ready)"
            echo "=========================================================="
            echo "Commands available:"
            echo "  run-nested   - Run nested Hyprland session with Quickshell"
            echo "  quickshell   - Run quickshell directly"
            echo "  serve-docs   - Serve local Quickshell docs at :8420"
            echo "                 (mirrors them on first run if not cached)"
            echo "  update-docs  - Force-refresh the local docs mirror"
            echo "=========================================================="
          '';
        };
      }
    );
}
