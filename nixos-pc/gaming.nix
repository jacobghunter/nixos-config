{ pkgs, ... }:

{
  # Zen Kernel for low-latency desktop/gaming scheduling
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Enable GPU recovery for AMD driver hangs and enable active AMD P-State driver
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amd_pstate=active"
  ];

  # Disable CFS autogroup scheduler to prevent game thread throttling
  boot.kernel.sysctl = {
    "kernel.sched_autogroup_enabled" = 0;
  };

  # Force AMDGPU to high performance level to prevent mixed-refresh-rate flickering
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  '';

  # SCX (sched-ext) userspace scheduler (scx_lavd)
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  # SteamOS customizations (max_map_count, file limits, split-lock mitigation)
  programs.steam.platformOptimizations.enable = true;

  # nix-gaming Cachix binary cache
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };

  # Low-latency Pipewire audio parameters
  services.pipewire.lowLatency = {
    enable = true;
    quantum = 512;
    rate = 48000;
  };

  # Gamescope window compositor micro-compositor
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };
}
