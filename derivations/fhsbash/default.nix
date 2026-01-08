{ pkgs, sources, ... }:


pkgs.buildFHSUserEnv {
  name = "fhsbash";

  targetPkgs = pkgs: with pkgs; [
    bashInteractive

    # Runtime libs Wine usually needs
    glibc
    zlib
    libGL
    mesa
    vulkan-loader
    alsa-lib
    pulseaudio

    # X11
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
  ];

  runScript = "bash";
}