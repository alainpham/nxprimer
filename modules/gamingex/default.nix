{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:

{
  
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
      "bin/cemu" = { 
        source = "${sources.dotfilesgit}/home/bin/cemu";
        force = true;
      };
      "bin/dolphin-emu" = { 
        source = "${sources.dotfilesgit}/home/bin/dolphin-emu";
        force = true;
      };

      ".config/PCSX2" = { 
        source = "${sources.dotfilesgit}/home/.config/PCSX2";
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

    };
  };


  environment.systemPackages = with pkgs; [
    pcsx2biospkg
    pcsx2
    dolphin-emu
    cemu
  ];

}
