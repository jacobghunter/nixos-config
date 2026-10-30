{ lib, ... }:

{
  options.modules.activeShell = lib.mkOption {
    type = lib.types.enum [
      "noctalia"
      "caelestia"
      "dms"
    ];
    default = "noctalia";
    description = "Which quickshell-based desktop shell to run. Only one is enabled at a time — change this and rebuild to swap.";
  };
}
