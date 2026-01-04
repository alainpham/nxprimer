{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
  pname = "pcsx2biospkg";
  version = "master";
  src = sources.pcsx2biospkgurl;
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/share/appdata/pcsx2/bios
    cp $src $out/share/appdata/pcsx2/bios/ps2-0230a-20080220.bin
  '';
}