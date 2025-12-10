{ config, lib, pkgs, ... }:

let
  # change this
  vars = import ./vars.nix;
  # end of change this

  # initial state version
  nixStateVersion ="25.11";
  
  # target version for fetching home-manager
  nixTargetVersion = "25.11";

  home-manager = builtins.fetchTarball (
    "https://github.com/nix-community/home-manager/archive/release-${nixTargetVersion}.tar.gz"
  );

  dotfilesgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dotfiles.git";
    ref = "master";
    rev = "51f25286a10879688b0e267ff793351e80ac653c";
  };

  # desktop related
  dwmgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dwm-flexipatch.git";
    ref = "master";
    rev = "aa9548f7ba29529f7c6dfa7d9be367bb424c9d40";
  };

  stgit = builtins.fetchGit {
    url = "https://github.com/alainpham/st-flexipatch.git";
    ref = "master";
    rev = "465a432f7dfb5ef01b2436fd35c0f8ee69920b06";
  };

  dmenugit = builtins.fetchGit {
    url = "https://github.com/alainpham/dmenu-flexipatch.git";
    ref = "master";
    rev = "90ad650797feab1d9768e93627301fd90b12b4fe";
  };

  slockgit = builtins.fetchGit {
    url = "https://github.com/alainpham/slock-flexipatch.git";
    ref = "master";
    rev = "b3eb868cfd11a493698afa97aa09afcceed4bf57";
  };

  dwmblocksgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dwmblocks.git";
    ref = "master";
    rev = "bf55e259f05b1f1e497dc63ed45f332ba1edd174";
  };

  appiconsgit = builtins.fetchGit {
    url = "https://github.com/alainpham/coloured-icons.git";
    ref = "master";
    rev = "1423f027d4af5d6aaa6e7b096626810bc36a6231";
  };


  # should not be set manually, but detect if running in vm
  isVm = lib.elem "virtio_console" config.boot.initrd.kernelModules;


  # custom packages

  # custom scripts & webapps
  scripts = pkgs.stdenv.mkDerivation {
      pname = "scripts";
      version = "master";

      src = dotfilesgit;

      installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/share/applications
        
        for dir in scripts/*/; do
         cp -r "$dir"* $out/bin/
        done

        cp shortcuts/* $out/share/applications/

        export APPDIR=$out/bin
        export SHORTCUTDIR=$out/share/applications
        bash "$src/webapps/genapps"

      '';
    };

  # application icons package
  appicons = pkgs.stdenv.mkDerivation {
    pname = "appicons";
    version = "master";
    src = appiconsgit;
    installPhase = ''
      mkdir -p $out/share/icons/hicolor/scalable/logos
      cp -r $src/public/logos/* "$out/share/icons/hicolor/scalable/logos"
    '';
  };

  # nvtop
  nvtop = pkgs.appimageTools.wrapType2 {
    pname = "nvtop";
    version = "3.2.0";

    src = builtins.fetchurl {
      url = "https://github.com/Syllo/nvtop/releases/download/3.2.0/nvtop-3.2.0-x86_64.AppImage";
      sha256 = "33c54fb7025f43a213db8e98308860d400db3349a61fc9382fe4736c7d2580c4";
      name = "nvtop.AppImage";
    };
  };


  # emulationstation
  emustation = pkgs.appimageTools.wrapType2 {
    pname = "estation";
    version = "3.4.0";

    src = builtins.fetchurl {
      url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/246875981/download";
      sha256 = "4cb66cfc923099711cfa0eddd83db64744a6294e02e3ffd19ee867f77a88ec7e";
      name = "estation.AppImage";
    };
  };


  # retroarch
  retroarchversion = "1.21.0";

  retroarchpkg = pkgs.stdenv.mkDerivation {
    pname = "retroarchpkg";
    version = retroarchversion;

    src = builtins.fetchurl {
      url = "https://buildbot.libretro.com/stable/${retroarchversion}/linux/x86_64/RetroArch.7z";
      sha256 = "294ea29d50adf281806dabae14f1a12b879c925ea5be15bc4de1068874d5236a";
    };

    buildInputs = [ pkgs.p7zip ];

    unpackPhase = ''
      7z x $src 
    '';

    installPhase = ''
      mkdir -p $out/share/appdata/retroarch
      mkdir -p $out/bin
      cp RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage $out/RetroArch.AppImage
      cp -r RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/* $out/share/appdata/retroarch/

      cat > $out/share/appdata/retroarch/ra-force.cfg <<EOF
        assets_directory = "/run/current-system/sw/share/appdata/retroarch/assets"
        libretro_directory = "/run/current-system/sw/share/appdata/retroarch/cores"
        libretro_info_path = "/run/current-system/sw/share/appdata/retroarch/cores"
        content_database_path = "/run/current-system/sw/share/appdata/retroarch/database/rdb"
        audio_filter_dir = "/run/current-system/sw/share/appdata/retroarch/filters/audio"
        video_filter_dir = "/run/current-system/sw/share/appdata/retroarch/filters/video"
        osk_overlay_directory = "/run/current-system/sw/share/appdata/retroarch/overlays/keyboards"
        overlay_directory = "/run/current-system/sw/share/appdata/retroarch/overlays"
        video_shader_dir = "/run/current-system/sw/share/appdata/retroarch/shaders"
        system_directory = "/run/current-system/sw/share/appdata/retroarch/system"
      EOF
    '';
  };

  retroarchcorespkg = pkgs.stdenv.mkDerivation {
    pname = "retroarchcorespkg";
    version = retroarchversion;

    src = builtins.fetchurl {
      url = "https://buildbot.libretro.com/stable/${retroarchversion}/linux/x86_64/RetroArch_cores.7z";
      sha256 = "cbf7c866f77259e6cc61243d2fcf4668471a0a7bf9be00649b84556b7bc22c57";
    };

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
    version = retroarchversion;

    src = builtins.fetchurl {
      url = "https://github.com/Abdess/retroarch_system/releases/download/v20220308/RetroArch_v1.10.1.zip";
      sha256 = "341c5011976e2e650ac991411daf74701327c26974b59b89f8a63b61cbb61b18";
    };

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
    version = retroarchversion;
    src = "${retroarchpkg}/RetroArch.AppImage";
    buildInputs = [ pkgs.makeBinaryWrapper ];

    extraInstallCommands = ''
      cat > $out/bin/retroarch << 'EOF'
      #!/bin/bash
      $out/bin/retroarchappimage --appendconfig ${retroarchpkg}/share/appdata/retroarch/ra-force.cfg|~/.config/retroarch/retroarch.override.cfg "$@"
      EOF
      chmod 755 $out/bin/retroarch
    '';
  };

  pcsx2bios = builtins.fetchurl {
    url = "https://github.com/archtaurus/RetroPieBIOS/raw/master/BIOS/pcsx2/bios/ps2-0230a-20080220.bin";
    sha256 = "f609ed1ca62437519828cdd824b5ea79417fd756e71a4178443483e3781fedd2";
  };

in
{
  imports =
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # fastboot
  boot.loader.timeout = 1;

  system.stateVersion = nixStateVersion;

  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.dns = "dnsmasq";

  environment.etc."NetworkManager/dnsmasq.d/dev.conf".text = ''
    #/etc/NetworkManager/dnsmasq.d/dev.conf
    local=/${vars.wildcardDomain}/
    address=/${vars.wildcardDomain}/172.18.0.1
  '';
  environment.etc."NetworkManager/dnsmasq.d/vms".source = "/home/${vars.targetUserName}/virt/runtime/vms";


  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "LatArCyrHeb-16";
    keyMap = vars.keyboardLayout;
  };

  users.groups = { 
    ${vars.targetUserName} = { };
  };

  # 
  users.users = {
    ${vars.targetUserName} = {
      isNormalUser = true;
      extraGroups = [ 
        "wheel"
        "docker"
        "audio"
        "video"
        "networkmanager"
        "libvirtd"
        "kvm"
        "input"
      ];
    };
  };

  environment.loginShellInit = ''
    export TARGET_USERNAME=${vars.targetUserName}
    export KEYBOARD_LAYOUT=${vars.keyboardLayout}
    export KEYBOARD_MODEL=${vars.keyboardModel}
    export WILDCARD_DOMAIN=${vars.wildcardDomain}
  '';

  home-manager.users.${vars.targetUserName} = { lib, ... }: {
    home.stateVersion = nixStateVersion;
    programs.git = {
      enable = true;
    };

    programs.bash = { 
      enable = true;
      profileExtra = builtins.readFile "${dotfilesgit}/home/.profile";
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
        
        codefld
        
        ROMs
        ES-DE/downloaded_media
        .config/retroarch/states
        .config/retroarch/saves

        .config/PCSX2/memcards
        .config/PCSX2/sstates
        .config/PCSX2/covers

        .local/share/Cemu/mlc01
      "
      for folder in $(echo $folders); do
        mkdir -p "$HOME/$folder"
      done
      touch "$HOME/virt/runtime/vms"

    '';
    };

    home.file = {
      # files at root of home
      ".xinitrc" = { 
        source = "${dotfilesgit}/home/.xinitrc";
        force = true;
      };
      ".gitconfig" = { 
        source = "${dotfilesgit}/home/.gitconfig"; 
        force = true;
      };
      ".gtkrc-2.0" = { 
        source = "${dotfilesgit}/home/.gtkrc-2.0"; 
        force = true;
      };
      # folders
      ".config" = { 
          source = "${dotfilesgit}/home/.config";
          recursive = true;
          force = true;
      };
      ".local" = { 
          source = "${dotfilesgit}/home/.local";
          recursive = true;
          force = true;
      };
      "ES-DE" = { 
          source = "${dotfilesgit}/home/ES-DE";
          recursive = true;
          force = true;
      };
      ".config/PCSX2/bios/ps2-0230a-20080220.bin" = {
        source = pcsx2bios;
        force = true;
      };
    };

  };

  ##################################################
  # passwordless sudo for users in wheel group
  ##################################################
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  ##################################################
  # small logs
  ##################################################
  services.journald.extraConfig = ''
    SystemMaxUse=50M
    SystemMaxFileSize=10M
  '';
  
  services.openssh.enable = true;
  
  ##################################################
  # passwordless sudo for users in wheel group
  ##################################################
  services.getty.autologinOnce = vars.automaticlogin;
  services.getty.autologinUser = vars.targetUserName;

  services.envfs.enable = true;

  ##################################################
  # enable spice agent only when running in a VM
  ##################################################
  services.spice-vdagentd.enable = isVm;

  ##################################################
  # disableturbo
  ##################################################
  systemd.services.disable-intel-turboboost = {
    enable = vars.disableTurboBoost;
    description = "disable-intel-turboboost";
    wantedBy = [ "sysinit.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      ExecStart = "${scripts}/bin/turboboost no";
      ExecStop = "${scripts}/bin/turboboost yes";
      RemainAfterExit = true;
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

    # Basic desktop applications
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
    cups
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
    ffmpeg
    fdk_aac
    yt-dlp
    google-chrome
    lxqt.pavucontrol-qt
    alsa-utils
    
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin
    xfce.xfconf

    flameshot
    maim
    xclip
    xdotool

    vscode
    
    moonlight-qt



    # all custom scripts & webapps
    scripts
    appicons


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
    pcsx2
    dolphin-emu
    cemu
  ];
  

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

  systemd.services.numLockOnTty = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.mkForce (pkgs.writeShellScript "numLockOnTty" ''
        for tty in /dev/tty{1..6}; do
            ${pkgs.kbd}/bin/setleds -D +num < "$tty";
        done
      '');
    };
  };
  hardware.graphics = {
    enable = true;
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

    displayManager.startx.enable = true;
  };
  services.udisks2.enable = true;
  services.picom.enable = true;

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

