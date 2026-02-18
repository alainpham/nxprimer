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
    
    kdePackages.kdenlive
    onlyoffice-desktopeditors
    mlv-app
    drawio
    viber
    freac
    sound-juicer
    localsend
    avidemux
    postman
    dbeaver-bin

  ];
}
