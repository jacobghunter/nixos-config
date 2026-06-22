{ pkgs, ... }:

{
  # Zen Kernel for low-latency desktop/gaming scheduling
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Enable GPU recovery for AMD driver hangs and enable active AMD P-State driver
  # (amdgpu.ppfeaturemask is commented out as it can cause instability on RDNA3 GPUs)
  # (vsyscall=emulate is required for games like THE FINALS / Easy Anti-Cheat to run under Proton)
  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amd_pstate=active"
    "vsyscall=emulate"
    # "amdgpu.ppfeaturemask=0xffff7fff"
  ];

  environment.systemPackages = [
    pkgs.protonup-qt
  ];

  # Enable low-latency PipeWire configuration from nix-gaming
  # Default quantum is 64 (1.3ms), which causes crackling/popping under heavy gaming load.
  # Raising it to 256 (5.3ms) ensures audio stability while keeping latency imperceptible.
  services.pipewire.lowLatency = {
    enable = true;
    quantum = 256;
  };

  # Force AMDGPU to high performance level to prevent mixed-refresh-rate flickering
  # services.udev.extraRules = ''
  #   ACTION=="add|change", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  # '';

  # Performance sysctl tweaks
  boot.kernel.sysctl = {
    # Disable CFS autogroup scheduler to prevent game thread throttling
    "kernel.sched_autogroup_enabled" = 0;

    # Prevent background writeback flushing from stalling disk I/O and causing game stutter.
    # On systems with high RAM, percentages (default) allow gigabytes of dirty pages to build up
    # before a massive flush stalls the drive. Forcing low byte thresholds writes to disk continuously in background.
    "vm.dirty_background_bytes" = 67108864; # 64MB
    "vm.dirty_bytes" = 268435456; # 256MB
  };

  # SCX (sched-ext) userspace scheduler (scx_lavd) (commented out to use zen's scheduler)
  # services.scx = {
  #   enable = true;
  #   scheduler = "scx_lavd";
  # };

  # SteamOS customizations (max_map_count, file limits, split-lock mitigation)
  programs.steam.platformOptimizations.enable = true;

  # nix-gaming Cachix binary cache
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };

  # Gamescope window compositor micro-compositor
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # CachyOS-inspired performance and stability tweaks
  zramSwap.enable = true;
  services.dbus.implementation = "broker";
  services.irqbalance.enable = true;

  # Increase Mesa shader cache size to prevent shader compilation stuttering over time.
  # Default is 1GB, raising to 5GB lets more games cache their compiled pipelines.
  environment.sessionVariables = {
    MESA_SHADER_CACHE_MAX_SIZE = "5G";
  };
}
