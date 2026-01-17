{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "decklinksdk";
  version = "master";

  src = sources.decklinksdkurl;
  buildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    unzip $src
  '';
  
  installPhase = ''
    mkdir -p $out/include
    cp -r $src/include $out
  '';
}