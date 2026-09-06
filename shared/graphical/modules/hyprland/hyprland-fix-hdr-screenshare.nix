{
  lib,
  stdenv,
  fetchFromGitHub,
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
  pname = "hyprland-fix-hdr-screenshare";
  version = "unstable-cd6a8fb";

  src = fetchFromGitHub {
    owner = "yayuuu";
    repo = "hyprland-fix-hdr-screenshare";
    rev = "cd6a8fbae550a970420679b4b71bf6f79194bf76";
    hash = "sha256-Nodgm1/BvDB/BQcvJY0+pm1IuMgnI3RdB11lNcBc7ok=";
  };

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
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '`pkg-config --cflags pixman-1 libdrm hyprland pangocairo libinput libudev wayland-server xkbcommon`' \
      '`pkg-config --cflags pixman-1 libdrm hyprland pangocairo libinput libudev wayland-server xkbcommon` ${extraCflags}'
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp fix-hdr-screenshare.so $out/lib/libhyprland-fix-hdr-screenshare.so
    runHook postInstall
  '';

  meta = with lib; {
    description = "Fixes frozen HDR screenshare and broken blur-under-HDR on Hyprland";
    homepage = "https://github.com/yayuuu/hyprland-fix-hdr-screenshare";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
