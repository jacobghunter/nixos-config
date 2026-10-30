{ lib, ... }:

{
  options.modules = {
    activeShell = lib.mkOption {
      type = lib.types.enum [
        "noctalia"
        "caelestia"
        "dms"
      ];
      default = "noctalia";
      description = "Which quickshell-based desktop shell to run. Only one is enabled at a time — change this and rebuild to swap.";
    };

    activeShellLauncherCmd = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Shell command that toggles the active shell's own app launcher, set by
        whichever shell module is currently enabled (caelestia/noctalia/dms
        each set this to their own IPC/CLI invocation). Consumed by the shared
        Hyprland config to bind a launcher key without hardcoding one shell's
        command there. Null falls back to a generic launcher (e.g. rofi).
      '';
    };
  };
}
