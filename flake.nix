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
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      disko,
      nixos-wsl,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # LAPTOP CONFIG
        nixos-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./laptop/configuration.nix
            ./laptop/hardware-configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-e15-intel
            inputs.vscode-server.nixosModules.default

            # ==========================================
            # DESKTOP ENVIRONMENT SELECTION (PICK ONE)
            # ==========================================

            # --- OPTION 1: HYPRLAND ---
            ./laptop/modules/hyprland/system.nix

            # --- OPTION 2: GNOME ---
            # ./laptop/modules/gnome/system.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };

              home-manager.backupFileExtension = "backup";

              # Here we merge your base home.nix with the DE-specific home.nix
              home-manager.users.jacob = {
                imports = [
                  ./laptop/home.nix # Always import base config

                  # --- OPTION 1: HYPRLAND HOME ---
                  ./laptop/modules/hyprland/home.nix

                  # --- OPTION 2: GNOME HOME ---
                  # ./laptop/modules/gnome/home.nix
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
            disko.nixosModules.disko
            inputs.vscode-server.nixosModules.default
            ./server/configuration.nix
            ./server/disk-config.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jacob = import ./server/home.nix;
            }
          ];
        };

        # WSL CONFIG
        nixos-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.vscode-server.nixosModules.default
            ./wsl/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jacob = import ./wsl/home.nix;
            }
          ];
        };
      };
    };
}
