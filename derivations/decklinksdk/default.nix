{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "decklinksdk";
  version = "master";

  src = sources.decklinksdkurl;
  
  installPhase = ''
    mkdir -p $out/include
    cp -r $src/include $out
  '';
}