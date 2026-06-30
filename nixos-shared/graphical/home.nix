{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    "${inputs.self}/nixos-shared/home.nix"
    ./modules/firefox/firefox.nix
    inputs.nixcord.homeModules.nixcord
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "24.11";

  home.shellAliases = {
    hyprbinds = "hyprctl binds";
  };

  home.packages = with pkgs; [
    # Applications
    vscode
    brave
    obsidian
    bitwarden-desktop
    remmina
    copyq

    # Books
    calibre

    pkgs.mpv
    cava
    hyprsunset

    # Games
    heroic
    love

    # Dev Tools
    cmake

    # Electronics / Hardware
    kicad-small
  ];

  # --- PROGRAMS CONFIGURATION ---

  modules.firefox = {
    enable = true;
    tabManager = "sideberry";
    hdr = false;
  };

  programs.home-manager.enable = true;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

  services.easyeffects.enable = true;

  xdg.configFile."wireplumber/wireplumber.conf.d/51-set-profile.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          {
            device.name = "alsa_card.usb-Samson_Technologies_Samson_Q2U_Microphone-00"
          }
        ]
        actions = {
          update-props = {
            device.profile = "output:analog-stereo+input:analog-stereo"
          }
        }
      }
    ]
  '';

  # --- DEFAULT TO FIREFOX ---
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "application/pdf" = "firefox.desktop";
      "application/x-extension-pdf" = "firefox.desktop";
      "application/x-pdf" = "firefox.desktop";
      "application/vnd.adobe.pdf" = "firefox.desktop";
    };
  };

  programs.nixcord = {
    enable = true;
    discord = {
      vencord.enable = false;
      equicord.enable = true;
    };
    config = {
      useQuickCss = true;
      themeLinks = [
        "https://discordstyles.github.io/DarkMatter/DarkMatter.theme.css"
      ];
      plugins = {
        # QoL
        fixSpotifyEmbeds.enable = true;
        messageLogger.enable = true;
        showHiddenChannels.enable = true;
        musicControls.enable = true;
        silentTyping.enable = true;
        betterRoleContext.enable = true;
        copyEmojiMarkdown.enable = true;
        permissionsViewer.enable = true;
        platformIndicators.enable = true;
        previewMessage.enable = true;
        readAllNotificationsButton.enable = true;
        reverseImageSearch.enable = true;
        translate.enable = true;
        viewIcons.enable = true;
      };
    };
  };

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.starryNight;
      colorScheme = "Base";
    };
  # {
  #   enable = true;
  #   theme = spicePkgs.themes.dribbblish;
  #   colorScheme = "dracula";
  # };
}
