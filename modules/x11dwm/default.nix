{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:
{

  services.xserver = {
    enable = true;
    xkb.layout = vars.keyboardLayout;
    xkb.model = vars.keyboardModel;
    xkb.variant = vars.keyboardVariant;
    displayManager.startx.enable = true;
  };

  # thunar
  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };
  ###############################
  # end dwm and X related services
  ###############################
  
  home-manager.users.${vars.targetUserName} = { lib, ... }: {
    
    programs.bash = { 
      # dwm related
      profileExtra = builtins.readFile "${sources.dotfilesgit}/home/.profile";
    };

    home.activation = {

      enablePicom = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ${toString vars.enablePicom} ]; then
          echo picom enabled
        else
          echo picom disabled
          touch "$HOME/.nopicom"
        fi
      '';
      
      numlockOnBoot = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ${toString vars.numlockOnBoot} ]; then
          echo numlock on boot enabled
        else
          echo numlock on boot disabled
          touch "$HOME/.nonumlock"
        fi
      '';
    };

    home.file = {
      # files at root of home

      # dwm related
      ".xinitrc" = { 
        source = "${sources.dotfilesgit}/home/.xinitrc";
        force = true;
      };

      # config folders
      
      ".config/dunst" = { 
          source = "${sources.dotfilesgit}/home/.config/dunst";
          recursive = true;
          force = true;
      };

      ".config/jgmenu" = { 
          source = "${sources.dotfilesgit}/home/.config/jgmenu";
          recursive = true;
          force = true;
      };

      ".config/picom" = { 
          source = "${sources.dotfilesgit}/home/.config/picom";
          recursive = true;
          force = true;
      };

      # dwm related
      ".config/Thunar" = { 
          source = "${sources.dotfilesgit}/home/.config/Thunar";
          recursive = true;
          force = true;
      };

      # dwm related
      ".config/xfce4" = { 
          source = "${sources.dotfilesgit}/home/.config/xfce4";
          recursive = true;
          force = true;
      };

      # .local
      ".local/share/dwm" = { 
          source = "${sources.dotfilesgit}/home/.local/share/dwm";
          recursive = true;
          force = true;
      };
    };

  };


  environment.systemPackages = with pkgs; [
    # dwm related
    xorg.xwininfo

    # dwm related
    wmctrl

    # dwm related
    (dwm.overrideAttrs (oldAttrs: rec {
      src = sources.dwmgit;
    }))

    # dwm related
    (st.overrideAttrs (oldAttrs: rec {
      src = sources.stgit;
    }))

    # dwm related
    (dmenu.overrideAttrs (oldAttrs: rec {
      src = sources.dmenugit;
    }))

    # dwm related
    (slock.overrideAttrs (oldAttrs: rec {
      src = sources.slockgit;
      buildInputs = oldAttrs.buildInputs ++ [ xorg.libXinerama imlib2];  
    }))

    # dwm related
    (dwmblocks.overrideAttrs (oldAttrs: rec {
      src = sources.dwmblocksgit;
    }))

    # dwm related
    numlockx
    arandr
    picom
    jgmenu

    # dwm related
    flameshot
    maim
    xclip
    xdotool
  ];
}
