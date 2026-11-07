{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.orcaSlicer;

  pname = "orca-slicer";
  version = "2.3.2";
  src = pkgs.fetchurl {
    url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_AppImage_Ubuntu2404_V${version}.AppImage";
    sha256 = "1n2afc153fl1pxzif65z0921hkhjynmblp37drv43n9pxk73chy6";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
{
  options.modules.orcaSlicer = {
    enable = lib.mkEnableOption "Orca Slicer, with the printer/filament/process profiles from configs/orca";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (symlinkJoin {
        name = "orca-slicer";
        paths = [
          (appimageTools.wrapType2 {
            inherit pname version src;
            extraPkgs =
              pkgs: with pkgs; [
                webkitgtk_4_1
                libsoup_3
                sqlite
                libmspack
                bzip2.out
              ];
            # wrapType2 only installs bin/ - without the AppImage's desktop
            # entry and icon, app launchers never list it. Its Exec=AppRun
            # only makes sense inside the AppImage, so point it at our binary.
            extraInstallCommands = ''
              install -Dm644 ${appimageContents}/OrcaSlicer.desktop \
                $out/share/applications/OrcaSlicer.desktop
              substituteInPlace $out/share/applications/OrcaSlicer.desktop \
                --replace-fail "Exec=AppRun" "Exec=${pname}"
              install -Dm444 ${appimageContents}/resources/images/OrcaSlicer.svg \
                $out/share/icons/hicolor/scalable/apps/OrcaSlicer.svg
            '';
          })
        ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/orca-slicer \
            --prefix LD_LIBRARY_PATH : "${bzip2.out}/lib"
        '';
      })
    ];

    xdg.configFile."OrcaSlicer/user/default" = {
      source = "${inputs.self}/configs/orca";
      recursive = true;
    };
  };
}
