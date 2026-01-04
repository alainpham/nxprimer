{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:

{
  
  # imports = [
  # ];

  # home-manager.users.${vars.targetUserName} = { lib, ... }:{

  #   # create folders and empty files

  #   home.file = {
  #     # folders
  #     "bin" = { 
  #         source = "${sources.dotfilesgit}/home/bin";
  #         recursive = true;
  #         force = true;
  #     };
  #     # emulation configs
  #     "ES-DE" = { 
  #         source = "${sources.dotfilesgit}/home/ES-DE";
  #         recursive = true;
  #         force = true;
  #     };

  #     ".config/PCSX2/bios/ps2-0230a-20080220.bin" = {
  #       source = "${pkgs.pcsx2biospkg}/share/appdata/pcsx2/bios/ps2-0230a-20080220.bin";
  #       force = true;
  #     };

  #     # retroarch folders
  #     ".config/retroarch/assets" = {
  #       source = "${pkgs.retroarchpkg}/share/appdata/retroarch/assets";
  #       force = true;
  #     };

  #     ".config/retroarch/cores" = {
  #       # source = "/run/current-system/sw/share/appdata/retroarch/cores";
  #       source = pkgs.symlinkJoin {
  #         name = "merged-core-folder";
  #         paths = [
  #         "${pkgs.retroarchcorespkg}/share/appdata/retroarch/cores"
  #         "${pkgs.retroarchpkg}/share/appdata/retroarch/cores"
  #         ];
  #       };
  #       force = true;
  #     };

  #     ".config/retroarch/filters" = {
  #       source = "${pkgs.retroarchpkg}/share/appdata/retroarch/filters";
  #       force = true;
  #     };

  #     ".config/retroarch/overlays" = {
  #       source = "${pkgs.retroarchpkg}/share/appdata/retroarch/overlays";
  #       force = true;
  #     };

  #     ".config/retroarch/shaders" = {
  #       source = "${pkgs.retroarchpkg}/share/appdata/retroarch/shaders";
  #       force = true;
  #     };

  #     ".config/retroarch/system" = {
  #       source = "${pkgs.retroarchbiospkg}/share/appdata/retroarch/system";
  #       force = true;
  #     };
  #   };
  # };

  
  # environment.systemPackages = with pkgs; [

  #   # workstation desktop apps
  #   handbrake
  #   libdvdcss
  #   gimp3
  #   rawtherapee
  #   krita
  #   mypaint
  #   pinta
  #   inkscape
  #   blender
  #   godot
  #   easytag
  #   audacity
    
  #   kdePackages.kdenlive
  #   onlyoffice-desktopeditors
  #   mlv-app
  #   drawio
  #   viber
  #   freac
  #   localsend
  #   avidemux
  #   postman
  #   dbeaver-bin

  #   estation
  #   retroarchpkg
  #   retroarchcorespkg
  #   retroarchbiospkg
  #   retroarchappimage
  #   pcsx2biospkg
  #   pcsx2
  #   dolphin-emu
  #   cemu

  #   # windows games compatibility experimental
  #   lutris
  #   # wineWowPackages.stable
  #   # winetricks
  #   # steam

  #   gshorts
  #   sdl-jstest
  #   linuxConsoleTools
  #   jstest-gtk
  #   antimicrox
  # ];



  
}

