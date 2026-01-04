{ pkgs, sources, ... }:

pkgs.appimageTools.wrapType2 {
  pname = "retroarchappimage";
  version = "master";
  src = "${pkgs.retroarchpkg}/RetroArch.AppImage";
  buildInputs = [ pkgs.makeBinaryWrapper ];

  extraInstallCommands = ''
    cat > $out/bin/retroarch << 'EOF'
    #!/bin/bash
    retroarchappimage --appendconfig ~/.config/retroarch/retroarch.override.cfg "$@"
    EOF
    chmod 755 $out/bin/retroarch
  '';
}