{ ... }:

{
  xdg.configFile."hypr/scripts/toggle_special.sh" = {
    source = ./scripts/toggle_special.sh;
    executable = true;
  };
  xdg.configFile."hypr/scripts/toggle_workspace_special.sh" = {
    source = ./scripts/toggle_workspace_special.sh;
    executable = true;
  };
  xdg.configFile."hypr/scripts/toggle_audio.sh" = {
    source = ./scripts/toggle_audio.sh;
    executable = true;
  };
}
