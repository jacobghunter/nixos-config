{ pkgs, lib, inputs, ... }:

{
  # Neovim configuration with LazyVim
  programs.neovim = {
    enable = true;
    defaultEditor = false;
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
    ];
  };

  # Declaratively manage the LazyVim starter configuration.
  # This symlinks the starter config to ~/.config/nvim.
  # LazyVim is smart enough to handle a read-only config and will
  # install plugins and user data in ~/.local/share/nvim/
  xdg.configFile."nvim" = {
    source = inputs.lazyvim-starter;
    recursive = true;
  };
}
