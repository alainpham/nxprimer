{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "iconspkg";
  version = "master";

  src = sources.dotfilesgit;

  installPhase = ''
    mkdir -p $out/share/icons
    cp $src/icons/* "$out/share/icons/"
  '';
}