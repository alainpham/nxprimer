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

  
  services.udisks2.enable = true;
  services.upower.enable = true;
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

  ###############################
  # sound
  ###############################

  boot.kernelModules = [ 
    "snd-dummy"
    "snd_aloop"
  ];
  boot.extraModprobeConfig = ''
    options snd-aloop index=10 id=loop
    options snd-dummy index=11 id=dummy
  '';

  services.udev.extraRules = lib.mkAfter 
    ''
      ATTR{id}=="dummy", ATTR{number}=="11",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
      ATTR{id}=="loop", ATTR{number}=="10",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1"
      ATTR{id}=="C920", SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
      KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
    '';

  services.pipewire.enable = false;
  services.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  ###############################
  # end sound
  ###############################

  services.printing = {
    enable = true;       # enables CUPS
    # package = pkgs.altVersion.cups;
  };

  # remote access
  services.sunshine.enable = true;
  services.sunshine.autoStart = false;
  services.sunshine.openFirewall = true;
  
  # syncthing
  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;
  #   guiAddress = "0.0.0.0:8384";
  #   user = "${vars.targetUserName}";
  #   group = "users";
  #   settings.options.urAccepted = -1;
  #   configDir = "/home/${vars.targetUserName}/.local/state/syncthing/";
  # };
  
  # networking.firewall.allowedTCPPorts = [ 8384 ];

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

  home-manager.users.${vars.targetUserName} = { lib, ... }: {
    
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

      ".gtkrc-2.0" = { 
        source = "${sources.dotfilesgit}/home/.gtkrc-2.0"; 
        force = true;
      };

      ".icons/default/index.theme" = { 
          source = "${sources.dotfilesgit}/home/.icons/default/index.theme";
          force = true;
      };

      ".local/share/icons/default/index.theme" = { 
          source = "${sources.dotfilesgit}/home/.local/share/icons/default/index.theme";
          force = true;
      };

      ".config/mimeapps.list" = { 
        source = "${sources.dotfilesgit}/home/.config/mimeapps.list";
        force = true;
      };

      # config folders
      
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

      ".config/dconf" = { 
          source = "${sources.dotfilesgit}/home/.config/dconf";
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


      # .local
      ".local/share/applications/bluetui.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/share/applications/bluetui.desktop";
          force = true;
      };
      ".local/share/applications/ctext.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/share/applications/ctext.desktop";
          force = true;
      };
      ".local/share/applications/nmtui.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/share/applications/nmtui.desktop";
          force = true;
      };
      ".local/share/applications/code.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/share/applications/code.desktop";
          force = true;
      };
      ".local/share/applications/code-url-handler.desktop" = { 
          source = "${sources.dotfilesgit}/home/.local/share/applications/code-url-handler.desktop";
          force = true;
      };
      "bin/code" = { 
        source = "${sources.dotfilesgit}/home/bin/code";
        force = true;
      };
      "bin/vdl" = { 
        source = "${sources.dotfilesgit}/home/bin/vdl";
        force = true;
      };
      "bin/adl" = { 
        source = "${sources.dotfilesgit}/home/bin/adl";
        force = true;
      };
      ".config/Code/User/settings.json" = { 
        source = "${sources.dotfilesgit}/home/.config/Code/User/settings.json";
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

    rofi
    usbutils
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

    mkvtoolnix
    imagemagick
    mediainfo-gui
    mediainfo

    brightnessctl
    filezilla
    speedcrunch
    font-awesome
    lxappearance
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.breeze-gtk
    adwaita-icon-theme

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
    
    xarchiver
    ghostscript
    vscode
       
    moonlight-qt

    guiscripts
    webapps
    iconspkg

  ];
}
