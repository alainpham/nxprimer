{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "retroarchcorespkg";
  version = "master";

  src = sources.retroarchcorespkgurl;

  buildInputs = [ pkgs.p7zip ];

  unpackPhase = ''
    7z x $src 
  '';

  installPhase = ''
    mkdir -p $out/share/appdata/retroarch
    cp -r RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/* $out/share/appdata/retroarch/
  '';
}