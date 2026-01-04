{ pkgs, sources, ... }:

stdenv.mkDerivation {
    pname = "scripts";
    version = "master";

    src = sources.dotfilesgit;

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      
      for dir in scripts/*/; do
        cp -r "$dir"* $out/bin/
      done

      export APPDIR=$out/bin
      export SHORTCUTDIR=$out/share/applications
      bash "$src/webapps/genapps"
      mkdir -p $out/share/icons
      cp -r $src/icons/* "$out/share/icons/"
    '';
  }; 