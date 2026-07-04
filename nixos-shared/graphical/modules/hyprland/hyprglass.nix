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
  pname = "hyprglass";
  version = "0.6.2";

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
      --replace-fail '$(shell pkg-config --cflags hyprland pixman-1 libdrm)' \
      '$(shell pkg-config --cflags hyprland pixman-1 libdrm) ${extraCflags}'
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp hyprglass.so $out/lib/libhyprglass.so
    runHook postInstall
  '';

  meta = with lib; {
    description = "Frosted glass effects for transparent windows in Hyprland";
    homepage = "https://github.com/hyprnux/hyprglass";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
