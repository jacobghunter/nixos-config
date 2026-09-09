{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.obsidian;
in
{
  options.modules.obsidian = {
    enable = lib.mkEnableOption "obsidian";
  };

  config = lib.mkIf cfg.enable {
    programs.obsidian = {
      enable = true;
      cli.enable = true;

      vaults."Documents/Obsidian".enable = true;

      defaultSettings = {
        # Mirrors core-plugins.json on the live vault - only plugins listed
        # here end up enabled, everything else in corePluginsList defaults
        # to off.
        corePlugins = [
          "file-explorer"
          "global-search"
          "switcher"
          "graph"
          "backlink"
          "canvas"
          "outgoing-link"
          "tag-pane"
          "page-preview"
          "daily-notes"
          "templates"
          "note-composer"
          "command-palette"
          "editor-status"
          "bookmarks"
          "outline"
          "word-count"
          "file-recovery"
          "sync"
          "bases"
          "webviewer"
          "slides"
        ];

        # Every plugin currently installed in plugins/, regardless of
        # whether it's in today's active list - matches pkg ids exactly
        # against karaolidis/nix-obsidian-extensions' registry.
        communityPlugins = with pkgs.obsidianPlugins; [
          calendar
          dataview
          obsidian-advanced-slides
          obsidian-excalidraw-plugin
          obsidian-icon-folder
          obsidian-kanban
          obsidian-linter
          obsidian-tasks-plugin
          omnisearch
          remotely-save
          table-editor-obsidian
        ];

        # No community theme: Obsidianite (and most themes) hardcode their
        # own hex values and never read --color-base-*/named accent vars,
        # so the tinty snippet below has nothing to override. Obsidian's
        # own stock appearance is fully driven by those vars (confirmed
        # against its bundled CSS - --interactive-normal, --text-accent,
        # etc. all cascade from --color-base-*/--color-accent), so staying
        # on the default theme is what actually makes tinty theming work.
        # If a community theme is picked later, prefer one that composes
        # with this variable set rather than replacing it outright.

        # Registered manually (not via cssSnippets) for two different
        # reasons per file:
        # - tinty.css is intentionally left unmanaged by home-manager so
        #   tinty's obsidian-colors hook (shared/modules/tinty) can write to
        #   it directly on every `tinty apply`. Declaring it via cssSnippets
        #   would make home-manager own that path as a read-only store
        #   symlink, which the hook could never write to.
        # - Using cssSnippets for either file would also backfire here: the
        #   module auto-computes enabledCssSnippets FROM cssSnippets and
        #   that completely replaces (not merges with) this manual list, so
        #   declaring just one of the two files there would silently drop
        #   the other from appearance.json.
        appearance.enabledCssSnippets = [
          "tinty"
          "obsidianite-structure"
        ];
      };
    };

    # Structural (non-color) rules ported from the Obsidianite theme, static
    # so plain home-manager management is fine - see the file header for
    # what was kept/dropped/rewritten.
    home.file."Documents/Obsidian/.obsidian/snippets/obsidianite-structure.css".source =
      ./obsidianite-structure.css;
  };
}
