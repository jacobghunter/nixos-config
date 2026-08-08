{
  pkgs,
  inputs,
  ...
}:

{
  # Neovim configuration with LazyVim
  programs.neovim = {
    enable = true;
    withRuby = true;
    withPython3 = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      unzip
      wget
      lazygit
      gcc # For nvim-treesitter
      nodejs # For some LSPs and copilot.lua
      # Add cacert to fix potential SSL issues during plugin installation
      cacert
      # Nix language support: LSP, formatter, linters
      nixd
      nixfmt
      statix
      deadnix
      # Rust language support: LSP, formatter, linter
      # (rustc/cargo itself is left to per-project dev shells, not global here)
      rust-analyzer
      rustfmt
      clippy
    ];
  };

  # Declaratively manage the LazyVim starter configuration.
  # This symlinks the starter config to ~/.config/nvim.
  # LazyVim is smart enough to handle a read-only config and will
  # install plugins and user data in ~/.local/share/nvim/
  xdg = {
    configFile = {
      "nvim" = {
        source = inputs.lazyvim-starter;
        recursive = true;
      };
      "nvim/lua/plugins/kitty-scrollback.lua".source = ./kitty-scrollback.lua;
      "nvim/lua/plugins/nix-lang.lua".source = ./nix-lang.lua;
      "nvim/lua/plugins/rust-lang.lua".source = ./rust-lang.lua;
      "nvim/lua/plugins/tinted.lua".source = ./tinted.lua;
      "nvim/lua/config/options.lua".text =
        builtins.readFile "${inputs.lazyvim-starter}/lua/config/options.lua"
        + "\n"
        + builtins.readFile ./options.lua;
    };
  };
}
