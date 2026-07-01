{
  lib,
  stdenv,
  pkg-config,
  hyprlandPackage,
  aquamarine,
  hyprutils,
  hyprgraphics,
  hyprcursor,
  hyprlang,
  libxcb-wm,
  pixman,
  libdrm,
  pango,
  libinput,
  udev,
  wayland,
  libxkbcommon,
  libGL,
  glslang,
  libxcb-errors,
  lua,
  src,
}:

let
  extraIncludeDirs = [
    "${hyprlandPackage.dev}/include/hyprland/protocols"
    "${hyprlandPackage.dev}/include/hyprland/src"
    "${libdrm.dev}/include/libdrm"
  ];

  extraCflags = lib.concatStringsSep " " (map (d: "-I${d}") extraIncludeDirs);
in
stdenv.mkDerivation {
  pname = "hyprland-easymotion";
  version = "unstable";

  inherit src;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    hyprlandPackage
    aquamarine
    hyprutils
    hyprgraphics
    hyprcursor
    hyprlang
    libxcb-wm
    pixman
    libdrm
    pango
    libinput
    udev
    wayland
    libxkbcommon
    libGL
    glslang
    libxcb-errors
    lua
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '`pkg-config --cflags pixman-1 libdrm hyprland pangocairo`' \
      '`pkg-config --cflags pixman-1 libdrm hyprland pangocairo` ${extraCflags}'
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp hypreasymotion.so $out/lib/libhyprland-easymotion.so
    runHook postInstall
  '';

  meta = with lib; {
    description = "Easymotion navigation plugin for Hyprland";
    homepage = "https://github.com/zakk4223/hyprland-easymotion";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
