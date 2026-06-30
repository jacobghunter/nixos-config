{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.modules.firefox;
in
{
  options.modules.firefox = {
    enable = lib.mkEnableOption "Enable custom firefox setup";

    tabManager = lib.mkOption {
      type = lib.types.enum [
        "none"
        "sideberry"
        "treestyletab"
      ];
      default = "none";
      description = "Choose which tab manager to install/configure.";
    };

    hdr = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable experimental HDR support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkMerge [
      (lib.mkIf (cfg.tabManager == "sideberry") {
        ".mozilla/firefox/default/chrome" = {
          source = "${inputs.self}/configs/firefox/sideberry/chrome";
          recursive = true;
        };
      })
      (lib.mkIf (cfg.tabManager == "treestyletab") {
        ".mozilla/firefox/default/chrome" = {
          source = "${inputs.self}/configs/firefox/treestyletabs/chrome";
          recursive = true;
        };
      })
    ];

    programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";

      policies = {
        ExtensionSettings = lib.mkMerge [
          # Always installed extensions
          {
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            "sponsorBlocker@ajay.app" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
              installation_mode = "force_installed";
            };
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
            "vimium-c@gdh1995.cn" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
              installation_mode = "force_installed";
            };
          }
          # Conditional Tab Manager
          (lib.mkIf (cfg.tabManager == "sideberry") {
            "{3c078156-979c-498b-8990-85f7987dd929}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/file/4766841/sidebery-5.5.2.xpi";
              installation_mode = "force_installed";
            };
          })
          (lib.mkIf (cfg.tabManager == "treestyletab") {
            "treestyletab@piro.sakura.ne.jp" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
              installation_mode = "force_installed";
            };
          })
        ];
      };

      profiles.default = lib.mkMerge [
        {
          id = 0;
          name = "default";
          isDefault = true;
          settings = lib.mkMerge [
            {
              "browser.startup.homepage" = "https://duckduckgo.com";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "media.ffmpeg.vaapi.enabled" = true;
            }
            (lib.mkIf cfg.hdr {
              "gfx.wayland.hdr" = true;
              "gfx.color_management.hdr" = true;
              "gfx.color_management.mode" = 0; # HDR modes often require specific overrides
            })
            (lib.mkIf (!cfg.hdr) {
              "gfx.wayland.hdr" = false;
              "gfx.color_management.hdr" = false;
            })
          ];
          search = {
            force = true;
            default = "ddg";
          };
        }
      ];
    };
  };
}
