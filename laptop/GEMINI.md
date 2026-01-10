# NixOS Configuration Summary

## Overview
This repository contains a Flake-based NixOS configuration for user `jacob`. It is designed to be modular, separating system-level configuration from user-level Home Manager configuration, with specific modules for Desktop Environments (currently Hyprland).

## Structure
- **Core**:
  - `flake.nix`: Entry point. Uses `nixos-unstable`. Defines the `nixos` system.
  - `configuration.nix`: System-wide settings (Boot, Networking, Hardware, Users).
  - `home.nix`: Base Home Manager configuration (Packages, Git, Shell).
- **Modules**:
  - `modules/hyprland/`: Contains all Hyprland-specific logic.
    - `system.nix`: System-level Hyprland enable, Display Manager (SDDM), and essential GUI packages.
    - `home.nix`: User-level Hyprland config (Variables, Keybinds), Theming (GTK, Cursor), Waybar, and Rofi.

## Key Features

### 1. System
- **Boot**: `systemd-boot` with EFI support.
- **Graphics**: Intel drivers enabled with hardware acceleration.
- **Audio**: Pipewire (ALSA/PulseAudio compatibility).
- **Virtualization**: Docker enabled.
- **Networking**: NetworkManager, custom firewall rules for Weylus.

### 2. Desktop (Hyprland)
- **Window Manager**: Hyprland (Wayland).
- **Bar**: Waybar with custom CSS (rounded bottom corners) and JSONC config.
- **Launcher**: Rofi (via custom theme).
- **Theming**:
  - **Colors**: Cyan/Blue/Purple gradient theme defined in `modules/hyprland/home.nix`.
  - **Dark Mode**: Globally enforced via GTK settings (`Adwaita-dark`) and `dconf`.
  - **Cursor**: `Bibata-Modern-Classic`.
  - **Fonts**: `JetBrainsMono Nerd Font`.

### 3. User Environment
- **Shell**: Bash with custom aliases (`rebuild`, `hyperbinds`, etc.).
- **Dev Tools**: Node.js, Python, GCC, Make, Gemini CLI.
- **Apps**: Firefox, VSCode, Discord, Obsidian.

## Maintenance
- **Updates**: Auto-upgrades enabled (weekly).
- **Garbage Collection**: Weekly, deletes versions older than 7 days.
- **Rebuild Command**: `rebuild` alias triggers `nixos-rebuild switch --flake ~/nixos-config`.

---
*Last Updated: 2025-12-20*
