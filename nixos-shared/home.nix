{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    "${inputs.self}/nixos-shared/home-base.nix"
    "${inputs.self}/nixos-shared/modules/neovim/neovim.nix"
  ];

  config = {
    home.sessionVariables = {
      BROWSER = "firefox";
      DEFAULT_BROWSER = "firefox";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      PATH = "$HOME/.npm-global/bin:$PATH";
      GTK_THEME = "Adwaita:dark"; # Force dark mode for GTK/Electron/Chrome applications
    };

    # Environment variable manager for project directories
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true; # Enables the faster, caching Nix integration
    };

    # Replaces zsh history
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };

    programs.pay-respects = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      # Dev Tools
      nodejs
      lua
      pnpm
      python3
      gcc
      gnumake
      inputs.antigravity-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
