{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:
{

  # obs
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };

  home-manager.users.${vars.targetUserName} = { lib, ... }: {
    
    home.file = {
      # files at root of home

      # config folders
      ".config/obs-studio" = { 
          source = "${sources.dotfilesgit}/home/.config/obs-studio";
          recursive = true;
          force = true;
      };

      "bin/localsend" = { 
        source = "${sources.dotfilesgit}/home/bin/localsend";
        force = true;
      };
      "bin/obs" = { 
        source = "${sources.dotfilesgit}/home/bin/obs";
        force = true;
      };
      "bin/reaper" = { 
        source = "${sources.dotfilesgit}/home/bin/reaper";
        force = true;
      };
    };

  };

  environment.systemPackages = with pkgs; [
    # workstation desktop apps
    handbrake
    libdvdcss
    gimp3
    rawtherapee
    krita
    mypaint
    pinta
    inkscape
    blender
    godot
    easytag
    audacity
    reaper
    
    kdePackages.kdenlive
    onlyoffice-desktopeditors
    mlv-app
    drawio
    freac
    sound-juicer
    localsend
    avidemux
    postman
    dbeaver-bin

  ];
}
