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

        # Static pick for now - swap for a tinty-generated theme later.
        themes = [ pkgs.obsidianThemes.obsidianite ];
      };
    };
  };
}
