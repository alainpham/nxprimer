{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:

{
  
  services.udev.extraRules = lib.mkAfter
    ''
      # shanwan gamepad to inhibit keyboard input
      SUBSYSTEM=="input",ATTRS{id/vendor}=="20bc",ATTRS{id/product}=="5500",ATTRS{capabilities/key}=="1000002000000 39fad941d801 1c000000000000 0", RUN+="${pkgs.gamingscripts}/bin/inhibit-gpad-kbd"
    '';

  home-manager.users.${vars.targetUserName} = { lib, ... }:{

    # create folders and empty files

    home.file = {
      # files
      ".config/PCSX2/bios/ps2-0230a-20080220.bin" = {
        source = "${pkgs.pcsx2biospkg}/share/appdata/pcsx2/bios/ps2-0230a-20080220.bin";
        force = true;
      };
      ".local/share/applications/info.cemu.Cemu.desktop" = {
        source = "${sources.dotfilesgit}/home/.local/share/applications/info.cemu.Cemu.desktop";
        force = true;
      };
      ".local/share/applications/estation.desktop" = {
        source = "${sources.dotfilesgit}/home/.local/share/applications/estation.desktop";
        force = true;
      };
      "bin/cemu" = { 
        source = "${sources.dotfilesgit}/home/bin/cemu";
        force = true;
      };
      "bin/dolphin-emu" = { 
        source = "${sources.dotfilesgit}/home/bin/dolphin-emu";
        force = true;
      };
      "bin/estation" = { 
        source = "${sources.dotfilesgit}/home/bin/estation";
        force = true;
      };
      "bin/winege" = { 
        source = "${sources.dotfilesgit}/home/bin/winege";
        force = true;
      };

      # folders
      # emulation configs
      "ES-DE" = { 
        source = "${sources.dotfilesgit}/home/ES-DE";
        recursive = true;
        force = true;
      };

      ".config/Cemu" = { 
        source = "${sources.dotfilesgit}/home/.config/Cemu";
        recursive = true;
        force = true;
      };

      ".config/dolphin-emu" = { 
        source = "${sources.dotfilesgit}/home/.config/dolphin-emu";
        recursive = true;
        force = true;
      };

      # retroarch folders
      ".config/retroarch" = {
        source = "${sources.dotfilesgit}/home/.config/retroarch";
        recursive = true;
        force = true;
      };

      ".config/retroarch/assets" = {
        source = "${pkgs.retroarchpkg}/share/appdata/retroarch/assets";
        force = true;
      };

      ".config/retroarch/cores" = {
        # source = "/run/current-system/sw/share/appdata/retroarch/cores";
        source = pkgs.symlinkJoin {
          name = "merged-core-folder";
          paths = [
          "${pkgs.retroarchcorespkg}/share/appdata/retroarch/cores"
          "${pkgs.retroarchpkg}/share/appdata/retroarch/cores"
          ];
        };
        force = true;
      };

      ".config/retroarch/filters" = {
        source = "${pkgs.retroarchpkg}/share/appdata/retroarch/filters";
        force = true;
      };

      ".config/retroarch/overlays" = {
        source = "${pkgs.retroarchpkg}/share/appdata/retroarch/overlays";
        force = true;
      };

      ".config/retroarch/shaders" = {
        source = "${pkgs.retroarchpkg}/share/appdata/retroarch/shaders";
        force = true;
      };

      ".config/retroarch/system" = {
        source = "${pkgs.retroarchbiospkg}/share/appdata/retroarch/system";
        force = true;
      };
    };
  };

  environment.variables = {
    # for lutri
    PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION="python";
  };

  environment.systemPackages = with pkgs; [

    estation
    retroarchpkg
    retroarchcorespkg
    retroarchbiospkg
    retroarchappimage
    pcsx2biospkg
    pcsx2
    dolphin-emu
    cemu

    fhsrun
    winetricks
    umu-launcher

    gshorts
    sdl-jstest
    linuxConsoleTools
    jstest-gtk
    antimicrox
  ];

}
