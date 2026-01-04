{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "containerscripts";
  version = "master";

  src = sources.dotfilesgit;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/scripts/docker/* $out/bin/
    cp -r $src/scripts/kube/* $out/bin/
  '';
}