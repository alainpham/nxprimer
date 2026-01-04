{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:
{

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
    input = {
      General = {
        ClassicBondedOnly = false;
      };
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = vars.keyboardLayout;
    xkb.model = vars.keyboardModel;
    xkb.variant = vars.keyboardVariant;
    displayManager.startx.enable = true;
  };
  services.udisks2.enable = true;

  services.libinput.touchpad = {
    tapping = true;
    naturalScrolling = false;
    disableWhileTyping = true;
  };

  services.gvfs.enable = true;
  
  fonts.packages = with pkgs; [
    nerd-fonts.noto
    noto-fonts
  ];

  # sound
  boot.kernelModules = [ 
    "snd-dummy"
    "snd_aloop"
  ];
  boot.extraModprobeConfig = ''
    options snd-aloop index=10 id=loop
    options snd-dummy index=11 id=dummy
  '';

  # services.udev.extraRules = ''
  #   ATTR{id}=="dummy", ATTR{number}=="11",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
  #   ATTR{id}=="loop", ATTR{number}=="10",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1"
  #   ATTR{id}=="C920", SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
  #   # shanwan gamepad to inhibit keyboard input
  #   SUBSYSTEM=="input",ATTRS{id/vendor}=="20bc",ATTRS{id/product}=="5500",ATTRS{capabilities/key}=="1000002000000 39fad941d801 1c000000000000 0", RUN+="${pkgs.scripts}/bin/inhibit-gpad-kbd"
  # '';

  services.udev.extraRules = lib.mkAfter 
    ''
      ATTR{id}=="dummy", ATTR{number}=="11",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
      ATTR{id}=="loop", ATTR{number}=="10",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1"
      ATTR{id}=="C920", SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
    '';

  # services.udev.extraRules = lib.mkAfter
  #   ''
  #     # shanwan gamepad to inhibit keyboard input
  #     SUBSYSTEM=="input",ATTRS{id/vendor}=="20bc",ATTRS{id/product}=="5500",ATTRS{capabilities/key}=="1000002000000 39fad941d801 1c000000000000 0", RUN+="${pkgs.scripts}/bin/inhibit-gpad-kbd"
  #   '';

  services.pipewire.enable = false;
  services.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  services.printing = {
    enable = true;       # enables CUPS
    # package = pkgs.altVersion.cups;
  };

  # remote access
  services.sunshine.enable = true;
  services.sunshine.autoStart = false;
  services.sunshine.openFirewall = true;


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

  # obs
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
  
  # app images setup
  programs.appimage = {
    enable = true;
    binfmt = true;
  };


  users.users = {
    ${vars.targetUserName} = {
      extraGroups = [ 
        "audio"
        "video"
        "input"
      ];
    };
  };

  home-manager.users.${vars.targetUserName} = {
    
    programs.bash = { 
      profileExtra = builtins.readFile "${sources.dotfilesgit}/home/.profile";
    };

    home.activation = {
      homews = lib.hm.dag.entryAfter ["writeBoundary"] ''
        folders="
          workspaces
          recordings
        "
        for folder in $(echo $folders); do
          if [ ! -L "$HOME/$folder" ] && [ ! -d "$HOME/$folder" ]; then
            mkdir -p "$HOME/$folder"
          fi
        done
      '';

      enablePicom = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ${toString vars.enablePicom} ]; then
          echo picom enabled
        else
          echo picom disabled
          touch "$HOME/.nopicom"
        fi
      '';
      
      sunshineOnBoot = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ${toString vars.sunshineOnBoot} ]; then
          touch "$HOME/.shunshineonboot"
        else
          echo sunshine on boot disabled
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
      ".xinitrc" = { 
        source = "${sources.dotfilesgit}/home/.xinitrc";
        force = true;
      };
      ".gtkrc-2.0" = { 
        source = "${sources.dotfilesgit}/home/.gtkrc-2.0"; 
        force = true;
      };
      ".config/libinput-gestures.conf" = { 
        source = "${sources.dotfilesgit}/home/.config/libinput-gestures.conf";
        force = true;
      };
      ".config/mimeapps.list" = { 
        source = "${sources.dotfilesgit}/home/.config/mimeapps.list";
        force = true;
      };

      # config folders
      ".config/dunst" = { 
          source = "${sources.dotfilesgit}/home/.config/dunst";
          recursive = true;
          force = true;
      };
      ".config/gtk-3.0" = { 
          source = "${sources.dotfilesgit}/home/.config/gtk-3.0";
          recursive = true;
          force = true;
      };
      ".config/gtk-4.0" = { 
          source = "${sources.dotfilesgit}/home/.config/gtk-4.0";
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
      ".config/pulse" = { 
          source = "${sources.dotfilesgit}/home/.config/pulse";
          recursive = true;
          force = true;
      };
      ".config/rofi" = { 
          source = "${sources.dotfilesgit}/home/.config/rofi";
          recursive = true;
          force = true;
      };
      ".config/SpeedCrunch" = { 
          source = "${sources.dotfilesgit}/home/.config/SpeedCrunch";
          recursive = true;
          force = true;
      };
      ".config/Thunar" = { 
          source = "${sources.dotfilesgit}/home/.config/Thunar";
          recursive = true;
          force = true;
      };
      ".config/xfce4" = { 
          source = "${sources.dotfilesgit}/home/.config/xfce4";
          recursive = true;
          force = true;
      };

      # .local
      ".local/applications/bluetui.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/applications/bluetui.desktop";
          force = true;
      };
      ".local/applications/ctext.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/applications/ctext.desktop";
          force = true;
      };
      ".local/applications/nmtui.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/applications/nmtui.desktop";
          force = true;
      };
      ".local/dwm" = { 
          source = "${sources.dotfilesgit}/home/.local/dwm";
          recursive = true;
          force = true;
      };
    };

  };

  # chrome policies for extensions (ublock origin lite & bitwarden) & bookmarks
  environment.etc."opt/chrome/policies/managed/chrome-policies.json".text = ''
    {
      "ExtensionInstallForcelist": [
        "ddkjiahejlhfcafbddmgiahcphecmpfh",
        "nngceckbapebfimnlniiiahkandclblb"
      ],
      "BookmarkBarEnabled": true,
      "MetricsReportingEnabled": false,
      "ManagedBookmarks": [
        {
          "toplevel_name": "MKS"
        },
        {
          "name": "sunshine",
          "url": "https://localhost:47990/"
        },
        {
          "name": "local-syncthing",
          "url": "http://localhost:8384/"
        },
        {
          "name": "hub-syncthing",
          "url": "http://192.168.8.100:8384/"
        },
        {
          "name": "jellyfin",
          "url": "http://192.168.8.100:8096/"
        }
      ]
    }
  '';

  environment.systemPackages = with pkgs; [
    xorg.xwininfo
    wmctrl

    (dwm.overrideAttrs (oldAttrs: rec {
      src = sources.dwmgit;
    }))

    (st.overrideAttrs (oldAttrs: rec {
      src = sources.stgit;
    }))

    (dmenu.overrideAttrs (oldAttrs: rec {
      src = sources.dmenugit;
    }))

    (slock.overrideAttrs (oldAttrs: rec {
      src = sources.slockgit;
      buildInputs = oldAttrs.buildInputs ++ [ xorg.libXinerama imlib2];  
    }))

    (dwmblocks.overrideAttrs (oldAttrs: rec {
      src = sources.dwmblocksgit;
    }))

    rofi
    numlockx
    usbutils
    libinput-gestures
    SDL2
    ntfs3g
    ifuse
    mpv
    haruna
    vlc
    cmatrix
    nmon
    mesa-demos
    fastfetch
    feh
    qimgv
    kdePackages.kimageformats
    acpitool
    lm_sensors
    libnotify
    dunst
    mkvtoolnix
    imagemagick
    mediainfo-gui
    mediainfo
    arandr
    picom
    jgmenu
    brightnessctl
    xsane
    filezilla
    speedcrunch
    font-awesome
    lxappearance
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.breeze-gtk

    bluetui
    impala

    gparted
    vulkan-tools
    ffmpeg-full
    fdk_aac
    yt-dlp
    google-chrome
    lxqt.pavucontrol-qt
    alsa-utils
    

    flameshot
    maim
    xclip
    xdotool

    xarchiver
    ghostscript
    vscode
       
    moonlight-qt

    guiscripts
    iconspkg

  ];
}
