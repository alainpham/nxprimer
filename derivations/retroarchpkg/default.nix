{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "retroarchpkg";
  version = sources.retroarchversion;

  src = sources.retroarchpkgurl;

  buildInputs = [ pkgs.p7zip ];

  unpackPhase = ''
    7z x $src 
  '';

  installPhase = ''
    mkdir -p $out/share/appdata/retroarch
    mkdir -p $out/bin
    cp RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage $out/RetroArch.AppImage
    cp -r RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/* $out/share/appdata/retroarch/
  '';
}