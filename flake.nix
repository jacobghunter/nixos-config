{
  description = "Jacob's NixOS Monorepo";

  nixConfig = {
    extra-substituters = [
      "https://nix-gaming.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Update this to point to master at some point, its this way to build the hdr plugin to fix screenshare/blur

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.55.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # hyprland plugins
    # hyprspace = {
    #   url = "github:KZDKM/Hyprspace";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # Re-enable when updated for hyprland 55
    # hyprland-easymotion = {
    #   url = "github:zakk4223/hyprland-easymotion";
    #   inputs.hyprland.follows = "hyprland";
    # };
    hyprsplit.url = "github:shezdy/hyprsplit";
    hyprglass = {
      url = "github:hyprnux/hyprglass/v0.6.2";
      flake = false;
    };
    hyprland-easymotion = {
      url = "github:natchapman/hyprland-easymotion/lua_config";
      flake = false;
    };

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

    antigravity-cli.url = "github:xsen/antigravity-cli-nix";

    nixcord.url = "github:FlameFlag/nixcord";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
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
      antigravity-cli,
      nix-gaming,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # LAPTOP CONFIG
        nixos-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            # Host-specific configurations
            ./nixos-laptop/configuration.nix
            ./nixos-laptop/hardware-configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-e15-intel
            inputs.vscode-server.nixosModules.default

            # Shared configurations
            ./nixos-shared/system.nix
            ./nixos-shared/graphical/configuration.nix
            ./nixos-shared/modules/hyprland/system.nix

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs self; };
              home-manager.backupFileExtension = "backup";
              home-manager.users.jacob = {
                imports = [
                  ./nixos-laptop/home.nix
                  ./nixos-shared/home.nix
                  ./nixos-shared/graphical/home.nix
                  ./nixos-shared/modules/kitty/kitty.nix
                  ./nixos-shared/modules/wayle/wayle.nix
                  ./nixos-laptop/modules/hyprland/home.nix
                ];
              };
            }
          ];
        };

        # SERVER CONFIG
        nixos-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
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
              home-manager.extraSpecialArgs = { inherit inputs self; };
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
          specialArgs = { inherit inputs self; };
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
              home-manager.extraSpecialArgs = { inherit inputs self; };
              home-manager.users.jacob = {
                imports = [
                  ./nixos-wsl/home.nix
                  ./nixos-shared/home.nix
                  ./nixos-shared/modules/kitty/kitty.nix
                ];
              };
            }
          ];
        };

        # PC CONFIG
        nixos-pc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            # Host-specific configurations
            ./nixos-pc/configuration.nix
            ./nixos-pc/hardware-configuration.nix
            inputs.vscode-server.nixosModules.default

            # Shared configurations
            ./nixos-shared/system.nix
            ./nixos-shared/graphical/configuration.nix
            ./nixos-shared/modules/hyprland/system.nix
            inputs.nix-gaming.nixosModules.platformOptimizations
            inputs.nix-gaming.nixosModules.pipewireLowLatency

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs self; };
              home-manager.backupFileExtension = "backup";
              home-manager.users.jacob = {
                imports = [
                  ./nixos-pc/home.nix
                  ./nixos-shared/home.nix
                  ./nixos-shared/graphical/home.nix
                  ./nixos-shared/modules/kitty/kitty.nix
                  ./nixos-shared/modules/wayle/wayle.nix
                  ./nixos-pc/modules/hyprland/home.nix
                ];
              };
            }
          ];
        };
      };
    };
}
