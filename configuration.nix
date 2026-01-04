{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:

let
  # change this
  # end of change this

  # custom scripts & webapps
  # scripts = pkgs.stdenv.mkDerivation {
  #   pname = "scripts";
  #   version = "master";

  #   src = sources.dotfilesgit;

  #   installPhase = ''
  #     mkdir -p $out/bin
  #     mkdir -p $out/share/applications
      
  #     for dir in scripts/*/; do
  #       cp -r "$dir"* $out/bin/
  #     done

  #     export APPDIR=$out/bin
  #     export SHORTCUTDIR=$out/share/applications
  #     bash "$src/webapps/genapps"
  #     mkdir -p $out/share/icons
  #     cp -r $src/icons/* "$out/share/icons/"
  #   '';
  # };

  # nvtop
  nvtop = pkgs.appimageTools.wrapType2 {
    pname = "nvtop";
    version = "3.2.0";
    src = sources.nvtopurl;
  };

  # emulationstation
  emustation = pkgs.appimageTools.wrapType2 {
    pname = "estation";
    version = "3.4.0";
    src = sources.emustationurl;
  };


  # retroarch
  retroarchpkg = pkgs.stdenv.mkDerivation {
    pname = "retroarchpkg";
    version = sources.retroarchversion;

    src = sources.retroarchpkgurl;

    buildInputs = [ pkgs.p7zip ];

    unpackPhase = ''
      7z x $src 
    '';

    installPhase = ''
      mkdir -p $out/share/appdata/retroarch
      mkdir -p $out/bin
      cp RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage $out/RetroArch.AppImage
      cp -r RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/* $out/share/appdata/retroarch/
    '';
  };

  retroarchcorespkg = pkgs.stdenv.mkDerivation {
    pname = "retroarchcorespkg";
    version = sources.retroarchversion;

    src = sources.retroarchcorespkgurl;

    buildInputs = [ pkgs.p7zip ];

    unpackPhase = ''
      7z x $src 
    '';

    installPhase = ''
      mkdir -p $out/share/appdata/retroarch
      cp -r RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/* $out/share/appdata/retroarch/
    '';
  };


  retroarchbiospkg = pkgs.stdenv.mkDerivation {
    pname = "retroarchbiospkg";
    version = sources.retroarchversion;

    src = sources.retroarchbiosurl;
    buildInputs = [ pkgs.unzip ];

    unpackPhase = ''
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/share/appdata/retroarch/system
      cp -r system/* $out/share/appdata/retroarch/system
    '';
  };

  retroarchappimage = pkgs.appimageTools.wrapType2 {
    pname = "retroarchappimage";
    version = sources.retroarchversion;
    src = "${retroarchpkg}/RetroArch.AppImage";
    buildInputs = [ pkgs.makeBinaryWrapper ];

    extraInstallCommands = ''
      cat > $out/bin/retroarch << 'EOF'
      #!/bin/bash
      retroarchappimage --appendconfig ~/.config/retroarch/retroarch.override.cfg "$@"
      EOF
      chmod 755 $out/bin/retroarch
    '';
  };


  pcsx2biospkg = pkgs.stdenv.mkDerivation {
    pname = "pcsx2biospkg";
    version = "master";
    src = pkgs.fetchurl {
      url = "https://github.com/archtaurus/RetroPieBIOS/raw/master/BIOS/pcsx2/bios/ps2-0230a-20080220.bin";
      sha256 = "f609ed1ca62437519828cdd824b5ea79417fd756e71a4178443483e3781fedd2";
    };
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/share/appdata/pcsx2/bios
      cp $src $out/share/appdata/pcsx2/bios/ps2-0230a-20080220.bin
    '';
  };

  gshorts = pkgs.stdenv.mkDerivation {
    pname = "gshorts";
    version = "master";

    src = builtins.fetchGit {
      url = "https://github.com/alainpham/gshorts.git";
      ref = "master";
      rev = "dda21ee0407252346fd8839d12ce18952c76ac76";
    };
    nativeBuildInputs = [
      # autoconf
      # automake
      pkgs.pkg-config
      pkgs.SDL2
      pkgs.SDL2.dev
    ];
    buildInputs = [
      pkgs.SDL2
      pkgs.SDL2.dev
    ];

    buildPhase = ''
      make clean
      make
    '';
     
    installPhase = ''
      mkdir -p "$out/bin"
      cp gshorts "$out/bin/gshorts"
    '';
  };

in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  imports = [

  ];
  
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


  home-manager.useGlobalPkgs = true;
  home-manager.users.${vars.targetUserName} = { lib, ... }: {
    home.stateVersion = nixStateVersion;
    programs.git = {
      enable = true;
    };

    programs.bash = { 
      enable = true;
      profileExtra = builtins.readFile "${sources.dotfilesgit}/home/.profile";
    };

    # create folders and empty files
    home.activation = {
      init-homefld = lib.hm.dag.entryAfter ["writeBoundary"] ''

      folders="
        ssh
        
        virt/runtime
        virt/images
        
        workspaces
        recordings
      "
      for folder in $(echo $folders); do
        if [ ! -L "$HOME/$folder" ] && [ ! -d "$HOME/$folder" ]; then
          mkdir -p "$HOME/$folder"
        fi
      done
      touch "$HOME/virt/runtime/vms"

      sshkeyexists=$([ -f "$HOME/.ssh/id_"*".pub" ] && echo 1 || echo 0)

      if [ $sshkeyexists -eq 0 ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N  ""
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
      ".gitconfig" = { 
        source = "${sources.dotfilesgit}/home/.gitconfig"; 
        force = true;
      };
      ".gtkrc-2.0" = { 
        source = "${sources.dotfilesgit}/home/.gtkrc-2.0"; 
        force = true;
      };
      # folders
      "bin" = { 
          source = "${sources.dotfilesgit}/home/bin";
          recursive = true;
          force = true;
      };
      ".config" = { 
          source = "${sources.dotfilesgit}/home/.config";
          recursive = true;
          force = true;
      };
      ".local" = { 
          source = "${sources.dotfilesgit}/home/.local";
          recursive = true;
          force = true;
      };

      # emulation configs
      "ES-DE" = { 
          source = "${sources.dotfilesgit}/home/ES-DE";
          recursive = true;
          force = true;
      };

      ".config/PCSX2/bios/ps2-0230a-20080220.bin" = {
        source = "${pcsx2biospkg}/share/appdata/pcsx2/bios/ps2-0230a-20080220.bin";
        force = true;
      };

      # retroarch folders
      ".config/retroarch/assets" = {
        source = "${retroarchpkg}/share/appdata/retroarch/assets";
        force = true;
      };

      ".config/retroarch/cores" = {
        # source = "/run/current-system/sw/share/appdata/retroarch/cores";
        source = pkgs.symlinkJoin {
          name = "merged-core-folder";
          paths = [
          "${retroarchcorespkg}/share/appdata/retroarch/cores"
          "${retroarchpkg}/share/appdata/retroarch/cores"
          ];
        };
          
        force = true;

      };

      ".config/retroarch/filters" = {
        source = "${retroarchpkg}/share/appdata/retroarch/filters";
        force = true;
      };

      ".config/retroarch/overlays" = {
        source = "${retroarchpkg}/share/appdata/retroarch/overlays";
        force = true;
      };

      ".config/retroarch/shaders" = {
        source = "${retroarchpkg}/share/appdata/retroarch/shaders";
        force = true;
      };

      ".config/retroarch/system" = {
        source = "${retroarchbiospkg}/share/appdata/retroarch/system";
        force = true;
      };
    };
  };



  ##################################################
  # essentials
  ##################################################
  programs.git.enable = true;
  programs.tmux.enable = true;
  programs.vim.enable = true;
  programs.neovim.enable = true;
  programs.htop.enable = true;
  programs.gnupg.agent.enable = true;
  programs.bash = {
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        PROMPT_COLOR="1;31m"
        ((UID)) && PROMPT_COLOR="1;32m"
        if [ -n "$INSIDE_EMACS" ]; then
          # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
          PS1="\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
        else
          PS1="\[\033[$PROMPT_COLOR\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
        fi
        if test "$TERM" = "xterm"; then
          PS1="\[\033]2;\h:\u:\w\007\]$PS1"
        fi
      fi
  '';
  };
  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    # essentials
    curl
    wget
    ncdu
    dnsutils
    bmon
    btop
    nvtop
    zip
    unzip
    p7zip
    virt-what
    wireguard-tools
    jq
    jc
    sshfs
    iotop
    wakeonlan
    cloud-utils
    iperf
    dmidecode
    micro
    parted
    cryptsetup
    envsubst
    pciutils
    lshw
    libva-utils
    bchunk

    # dev environment
    ansible
    nodejs_24
    go
    maven

    # kubernetes
    k9s
    kubernetes-helm

    # virtualization todo
    cdrkit
    libosinfo

    # Basic desktop applications
    xorg.xwininfo
    wmctrl

    (dwm.overrideAttrs (oldAttrs: rec {
      src = dwmgit;
    }))

    (st.overrideAttrs (oldAttrs: rec {
      src = stgit;
    }))

    (dmenu.overrideAttrs (oldAttrs: rec {
      src = dmenugit;
    }))

    (slock.overrideAttrs (oldAttrs: rec {
      src = slockgit;
      buildInputs = oldAttrs.buildInputs ++ [ xorg.libXinerama imlib2];  
    }))

    (dwmblocks.overrideAttrs (oldAttrs: rec {
      src = dwmblocksgit;
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

    # all custom scripts & webapps
    scripts

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
    localsend
    avidemux
    postman
    dbeaver-bin

    emustation
    retroarchpkg
    retroarchcorespkg
    retroarchbiospkg
    retroarchappimage
    pcsx2biospkg
    pcsx2
    dolphin-emu
    cemu

    # windows games compatibility experimental
    lutris
    # wineWowPackages.stable
    # winetricks
    # steam

    gshorts
    sdl-jstest
    linuxConsoleTools
    jstest-gtk
    antimicrox
  ];

  services.printing = {
    enable = true;       # enables CUPS
    # package = pkgs.altVersion.cups;
  };

  ##################################################
  # Dev environment
  ##################################################
  programs.java.enable = true;
  programs.java.package = pkgs.jdk17_headless;


  ##################################################
  # Docker
  ##################################################
  virtualisation.docker.enable = true;

  systemd.services.firstboot-dockernet = {
    description = "firstboot-dockernet";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${scripts}/bin/firstboot-dockernet";
    };
  };

  systemd.services.firstboot-dockerbuildx = {
    description = "firstboot-dockerbuildx";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      User = vars.targetUserName;
      ExecStart = "${scripts}/bin/firstboot-dockerbuildx";
      RemainAfterExit = true;
    };
  };

  ##################################################
  # kubernetes
  ##################################################
  services.k3s = {
    enable = vars.enableKubernetes;
    extraFlags = [ 
      "--disable=traefik" 
      "--disable=servicelb"
      "--tls-san=${vars.wildcardDomain}"
      "--write-kubeconfig-mode=644"
    ];
  };
  # Disable k3s from starting at boot; we'll manage it manually
  systemd.services.k3s.wantedBy = lib.mkForce [ ];
  
  ##################################################
  # virtualization
  ##################################################
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  systemd.services.firstboot-virt = {
    enable = vars.enableVirtualization;
    description = "firstboot-virt";
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${scripts}/bin/firstboot-virt";
    };
  };

  ##################################################
  # gui
  ##################################################

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

  services.udev.extraRules = ''
    ATTR{id}=="dummy", ATTR{number}=="11",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
    ATTR{id}=="loop", ATTR{number}=="10",SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1"
    ATTR{id}=="C920", SUBSYSTEM=="sound", ENV{PULSE_IGNORE}="1",ENV{ACP_IGNORE}="1"
    # shanwan gamepad to inhibit keyboard input
    SUBSYSTEM=="input",ATTRS{id/vendor}=="20bc",ATTRS{id/product}=="5500",ATTRS{capabilities/key}=="1000002000000 39fad941d801 1c000000000000 0", RUN+="${scripts}/bin/inhibit-gpad-kbd"
  '';

  services.pipewire.enable = false;
  services.pulseaudio = {
    enable = true;
    support32Bit = true;
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

  
}

