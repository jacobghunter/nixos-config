{
  description = "Quickshell development environment";

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
          echo "Starting nested Hyprland with Quickshell..."
          # Run the system's Hyprland binary (from PATH) rather than the flake's version.
          # This prevents plugin version mismatch errors and matches your host setup.
          Hyprland -c ./nested.lua
        '';

        serveDocs = pkgs.writeShellScriptBin "serve-docs" ''
          DOCS_DIR="$HOME/.cache/quickshell-docs"
          SITE_DIR="$DOCS_DIR/quickshell.outfoxxed.me"

          if [ ! -d "$SITE_DIR" ]; then
            echo "No local copy found — mirroring Quickshell docs (needs network, one-time)..."
            mkdir -p "$DOCS_DIR"
            ${pkgs.wget}/bin/wget --mirror --convert-links --adjust-extension \
              --page-requisites --no-parent -P "$DOCS_DIR" \
              https://quickshell.outfoxxed.me/
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
