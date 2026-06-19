{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "treestyletab@piro.sakura.ne.jp" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
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
      };
    };

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "https://duckduckgo.com";
        "privacy.resistFingerprinting" = false; # Set to false to allow dark mode for pages/extensions
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "ui.systemUsesDarkTheme" = 1; # Force dark mode for Firefox UI and pages

        # Experimental HDR and Color Management on Wayland (Commented out: colors are currently washed out)
        # "gfx.wayland.hdr" = true;
        # "gfx.color_management.hdr" = true;
        # "gfx.color_management.mode" = 1;
        # "gfx.color_management.enablev4" = true;

        # Hardware video acceleration (VA-API) for efficient video decoding
        "media.ffmpeg.vaapi.enabled" = true;
      };
      search = {
        force = true;
        default = "ddg";
      };
      userChrome = builtins.readFile "${inputs.self}/configs/firefox/userChrome.css";
    };
  };
}
