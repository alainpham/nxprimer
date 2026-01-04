{ pkgs, sources, ... }:

pkgs.stdenv.mkDerivation {
    pname = "gshorts";
    version = "master";

    src = sources.gshortsgit;
    
    nativeBuildInputs = [
      # autoconf
      # automake
      pkgs.pkg-config
      pkgs.SDL2
      pkgs.SDL2.dev
    ];
    buildInputs = [
      pkgs.SDL2
      pkgs.SDL2.dev
    ];

    buildPhase = ''
      make clean
      make
    '';
     
    installPhase = ''
      mkdir -p "$out/bin"
      cp gshorts "$out/bin/gshorts"
    '';
  }