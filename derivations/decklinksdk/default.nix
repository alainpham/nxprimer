{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "decklinksdk";
  version = "master";

  src = sources.decklinksdkurl;
  
  buildInputs = [ pkgs.unzip ];

  installPhase = ''
    mkdir -p $out/include
    cp -r $src/Blackmagic\ DeckLink\ SDK\ */Linux/include $out
  '';
}