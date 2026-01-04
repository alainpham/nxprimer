{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "ossscripts";
  version = "master";

  src = sources.dotfilesgit;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/scripts/os/* $out/bin/
  '';
}