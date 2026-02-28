{
  description = "Jacob's NixOS Monorepo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    astal.url = "github:aylur/astal";
    ags.url = "github:aylur/ags";
    ags.inputs.astal.follows = "astal";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:msteen/nixos-vscode-server";

    # Server specific
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # WSL specific
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    lazyvim-starter = {
      url = "github:LazyVim/starter";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      disko,
      nixos-wsl,
      lazyvim-starter,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # LAPTOP CONFIG
        nixos-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Host-specific configurations
            ./nixos-laptop/configuration.nix
            ./nixos-laptop/hardware-configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-e15-intel
            inputs.vscode-server.nixosModules.default

            # Shared configurations
            ./nixos-shared/system.nix
            ./nixos-shared/graphical/configuration.nix

            # Hyprland specific
            ./nixos-laptop/modules/hyprland/system.nix

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.backupFileExtension = "backup";
              home-manager.users.jacob = {
                imports = [
                  ./nixos-laptop/home.nix
                  ./nixos-shared/home.nix
                  ./nixos-shared/graphical/home.nix
                  ./nixos-laptop/modules/hyprland/home.nix
                ];
              };
            }
          ];
        };

        # SERVER CONFIG
        nixos-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Host-specific configurations
            disko.nixosModules.disko
            inputs.vscode-server.nixosModules.default
            ./nixos-server/configuration.nix
            ./nixos-server/disk-config.nix
            ./nixos-server/pi-hole.nix

            # Shared configurations
            ./nixos-shared/system.nix

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.jacob = {
                imports = [
                  ./nixos-server/home.nix
                  ./nixos-shared/home.nix
                ];
              };
            }
          ];
        };

        # WSL CONFIG
        nixos-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Host-specific configurations
            inputs.vscode-server.nixosModules.default
            ./nixos-wsl/configuration.nix

            # Shared configurations
            ./nixos-shared/system.nix

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.jacob = {
                imports = [
                  ./nixos-wsl/home.nix
                  ./nixos-shared/home.nix
                ];
              };
            }
          ];
        };

        # PC CONFIG
        nixos-pc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Host-specific configurations
            ./nixos-pc/configuration.nix
            ./nixos-pc/hardware-configuration.nix
            inputs.vscode-server.nixosModules.default

            # Shared configurations
            ./nixos-shared/system.nix
            ./nixos-shared/graphical/configuration.nix

            # Hyprland specific
            ./nixos-pc/modules/hyprland/system.nix

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.backupFileExtension = "backup";
              home-manager.users.jacob = {
                imports = [
                  ./nixos-pc/home.nix
                  ./nixos-shared/home.nix
                  ./nixos-shared/graphical/home.nix
                  ./nixos-pc/modules/hyprland/home.nix
                ];
              };
            }
          ];
        };
      };
    };
}
