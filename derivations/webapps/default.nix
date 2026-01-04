{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "webapps";
  version = "master";

  src = sources.dotfilesgit;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    
    export APPDIR=$out/bin
    export SHORTCUTDIR=$out/share/applications
    bash "$src/webapps/genapps"
  '';
}