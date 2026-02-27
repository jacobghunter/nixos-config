{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Enable ZSH
  programs.zsh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };
  
  # Enable VS Code Server service (requires the module to be imported in flake.nix)
  services.vscode-server.enable = true;

  # Enable nix-ld for better compatibility with unpatched binaries (helpful for VS Code remote)
  programs.nix-ld.enable = true;

  # Common System Packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
  ];

  # Allow unfree packages (like VS Code)
  nixpkgs.config.allowUnfree = true;

  # Enable Nix Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Shared User Configuration
  users.users.jacob = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSF1X9Rhk/20YAwdqLI5zlZSIIZjL06/Rri8UZqv/Or jacob@nixos-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFX1rPVicE6akrUGmXwuP5C2qmLtJ22E+Od1ZsU/on0H jacob@Jacobs-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0WYLgYAAWBISrS7w+QTxPohk4xb8kHbBQIwlJWMCiY jacob@nixos-wsl"
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENlOaDve6NsoV4BfHjM0xbNnfwPOZzm4FQ+up6eHz9d jacob@nixos-pc
    ];
  };
}
