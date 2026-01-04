{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "guiscripts";
  version = "master";

  src = sources.dotfilesgit;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/scripts/desktop/* $out/bin/
    cp $src/scripts/sound/* $out/bin/
    cp $src/scripts/av/* $out/bin/
    cp $src/scripts/webcam/* $out/bin/
  '';
}