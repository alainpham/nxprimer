{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "gamingscripts";
  version = "master";

  src = sources.dotfilesgit;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/scripts/gaming/* $out/bin/
  '';
}