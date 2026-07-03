{
  config,
  pkgs,
  lib,
  inputs,
  osConfig ? null,
  ...
}:

let
  hostname = if osConfig != null then osConfig.networking.hostName else "nixos-laptop";
in
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
    nixd

    # Electronics / Hardware
    kicad-small

    qt6.qtdeclarative # ships qmlls, needed on every machine, not just inside a dev shell
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

  qt.enable = true;

  home.activation.quickshellLspInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    QMLLS_INI="${config.home.homeDirectory}/nixos-config/nixos-shared/modules/quickshell/.qmlls.ini"
    if [ ! -f "$QMLLS_INI" ]; then
      $DRY_RUN_CMD touch "$QMLLS_INI"
    fi
  '';

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions =
        with pkgs.vscode-extensions;
        [
          jnoortheen.nix-ide
          sumneko.lua
        ]
        ++ (with pkgs.nix-vscode-extensions.vscode-marketplace; [
          theqtcompany.qt-qml
          theqtcompany.qt-core
        ]);
      userSettings = {
        "editor.formatOnSave" = true;
        "git.autofetch" = true;
        "qt-qml.qmlls.useQmlImportPathEnvVar" = true;
        "qt-qml.qmlls.customExePath" = "${pkgs.qt6.qtdeclarative}/bin/qmlls";
        "qt-qml.qmlls.customArgs" = [
          "-E"
          "-I"
          "${pkgs.quickshell}/lib/qt-6/qml"
          "-I"
          "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
        ];
        "qt-qml.qmlPreviewLaunchEnabled" = false;
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "nixpkgs" = {
              "expr" = "import <nixpkgs> { }";
            };
            "options" = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"/home/jacob/nixos-config\").nixosConfigurations.${hostname}.options";
              };
            };
          };
        };
        "Lua.workspace.library" = [
          "/run/current-system/sw/share/hypr/stubs"
        ];
        "Lua.diagnostics.globals" = [
          "hl"
        ];
      };
    };
  };
}
