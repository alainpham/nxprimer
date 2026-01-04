{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "vmscripts";
  version = "master";

  src = sources.dotfilesgit;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/scripts/vm/* $out/bin/
  '';
}