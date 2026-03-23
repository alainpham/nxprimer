{ pkgs, sources, ... }:

pkgs.appimageTools.wrapType2 {
  pname = "ppssppappimage";
  version = "master";
  src = sources.ppssppurl;
  extraInstallCommands = ''
    cat > $out/bin/ppsspp << 'EOF'
    #!/bin/bash
    ppssppappimage  "$@"
    EOF
    chmod 755 $out/bin/ppsspp
  '';
}