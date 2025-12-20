{
  description = "Jacob's NixOS Flake";

  inputs = {
    # The source of your packages (NixOS Unstable is best for Hyprland)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-e15-intel

            # ==========================================
            # DESKTOP ENVIRONMENT SELECTION (PICK ONE)
            # ==========================================

            # --- OPTION 1: HYPRLAND ---
            ./modules/hyprland/system.nix

            # --- OPTION 2: GNOME ---
            # ./modules/gnome/system.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };

              home-manager.backupFileExtension = "backup";

              # Here we merge your base home.nix with the DE-specific home.nix
              home-manager.users.jacob = {
                imports = [
                  ./home.nix # Always import base config

                  # --- OPTION 1: HYPRLAND HOME ---
                  ./modules/hyprland/home.nix

                  # --- OPTION 2: GNOME HOME ---
                  # ./modules/gnome/home.nix
                ];
              };
            }
          ];
        };
      };
    };
}
