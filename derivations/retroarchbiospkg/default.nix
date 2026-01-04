{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "retroarchbiospkg";
  version = "master";

  src = sources.retroarchbiosurl;
  buildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/share/appdata/retroarch/system
    cp -r system/* $out/share/appdata/retroarch/system
  '';
}