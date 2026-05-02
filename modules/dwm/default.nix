{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:
{

  services.xserver = {
    enable = true;
    xkb.layout = vars.keyboardLayout;
    xkb.model = vars.keyboardModel;
    xkb.variant = vars.keyboardVariant;
    displayManager.startx.enable = true;
  };
  # services.displayManager.enable = false;
  # thunar
  programs.xfconf.enable = true;
  programs.dconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  environment.variables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-49.1/glib-2.0/schemas";
  };

  # slock  
  programs.slock.enable = true;
  programs.slock.package = pkgs.slock.overrideAttrs (oldAttrs: rec {
    src = sources.slockgit;
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.xorg.libXinerama pkgs.imlib2];
  });


  home-manager.users.${vars.targetUserName} = { lib, ... }: {
    

    home.activation = {

      enableStartx = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ${toString vars.enableStartx} ]; then
          echo startx enabled
          touch "$HOME/.startxon"
        else
          echo startx disabled
        fi
      '';

      enablePicom = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ${toString vars.enablePicom} ]; then
          echo picom enabled
        else
          echo picom disabled
          touch "$HOME/.nopicom"
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
      
      ".Xresources" = { 
        source = "${sources.dotfilesgit}/home/.Xresources";
        force = true;
      };

      ".config/libinput-gestures.conf" = { 
        source = "${sources.dotfilesgit}/home/.config/libinput-gestures.conf";
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
    xorg.xwininfo
    xorg.xdpyinfo
    xorg.xrdb
    wmctrl

    (dwm.overrideAttrs (oldAttrs: rec {
      src = sources.dwmgit;
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.xorg.libXcursor ];
      postPatch = (oldAttrs.postPatch or "") + ''
        sed -i '/^LIBS/s/$/ -lXcursor/' config.mk
      '';
    }))

    (st.overrideAttrs (oldAttrs: rec {
      src = sources.stgit;
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.xorg.libXcursor ];
      postPatch = (oldAttrs.postPatch or "") + ''
        sed -i '/^LIBS/s/$/ -lXcursor/' config.mk
      '';
    }))

    (dmenu.overrideAttrs (oldAttrs: rec {
      src = sources.dmenugit;
    }))

    (dwmblocks.overrideAttrs (oldAttrs: rec {
      src = sources.dwmblocksgit;
    }))

    numlockx
    libinput-gestures
    dunst

    arandr
    picom
    jgmenu
    xsane

    flameshot
    maim
    xclip
    xdotool
    xev
  ];
}
