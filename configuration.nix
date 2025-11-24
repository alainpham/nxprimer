{ config, lib, pkgs, ... }:

let
  # change this
  vars = import ./vars.nix;
  
  # end of change this
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

  home-manager = builtins.fetchTarball (
    "https://github.com/nix-community/home-manager/archive/release-${vars.nixversion}.tar.gz"
  );

  dotfilesgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dotfiles.git";
    ref = "master";
    rev = "9ca6cc64e7f918b096d4f60a33fda3ae5c1e5c6e";
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

        # webapps

        export WEBAPPSLIST="
          gpt|chatgpt-color|https://chatgpt.com
          gm|gmail-color|https://mail.google.com/mail/u/1/#inbox
          cal|google|https://calendar.google.com/calendar/u/1/r
          teams|teams|https://teams.microsoft.com/v2/
          whatsapp|whatsapp|https://web.whatsapp.com
          messenger|messenger|https://www.messenger.com
          telegram|telegram|https://web.telegram.org
          notes|onenote|https://docs.google.com/document/d/1wTwA1NhzgYUGG1eyDyUZj8ExhbhdscQrdYWBOBkLnCs
          gco|grafana|https://docs.google.com/presentation/d/1yo6Q0p0OBK9vIh3abwigtBDlFGMy9NqU7EzRKYjraro
          gdemo|grafana|https://emea.cloud.demokit.grafana.com/a/grafana-asserts-app/assertions?start=now-24h&end=now&search=productcatalogservice%20connected%20services&view=BY_ENTITY
          spotify|spotify|https://open.spotify.com/
          youtube|youtube|https://www.youtube.com/
          grok|grok|https://grok.com/
          sd|chatgpt-color|https://stablediffusionweb.com/app/image-generator
          brm|chatgpt-color|https://stablediffusionweb.com/background-remover
          word|word|https://word.cloud.microsoft
          excel|excel|https://excel.cloud.microsoft
          powerpoint|powerpoint|https://powerpoint.cloud.microsoft
          deezer|applemusic|https://www.deezer.com/
        "
        

        export APPDIR=$out/bin
        export SHORTCUTDIR=$out/share/applications
        bash "$src/webapps/genapps"

      '';
    };

    appicons = pkgs.stdenv.mkDerivation {
      pname = "appicons";
      version = "master";
      src = appiconsgit;
      installPhase = ''
        mkdir -p $out/share/icons/hicolor/scalable/logos
        cp -r $src/public/logos/* "$out/share/icons/hicolor/scalable/logos"
      '';
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

  system.stateVersion = vars.nixversion;

  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.dns = "dnsmasq";

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
        "libvirt"
        "kvm"
        "input"
      ];
    };
  };

  environment.loginShellInit = ''
    export TARGET_USER=${vars.targetUserName}
    export KEYBOARD_LAYOUT=${vars.keyboardLayout}
    export KEYBOARD_MODEL=${vars.keyboardModel}
    export PRODUCT_NAME=$(cat /sys/devices/virtual/dmi/id/product_name)
  '';

  home-manager.users.${vars.targetUserName} = {
    home.stateVersion = vars.nixversion;
    programs.git = {
      enable = true;
      userName = vars.targetUserName;
      userEmail = vars.targetUserEmail;
    };

    programs.bash = { 
      enable = true;
      profileExtra = builtins.readFile "${dotfilesgit}/home/.profile";
    };

    xfconf.settings = {
      "thunar" = {
        "last-view" = "ThunarDetailsView";
        "last-details-view-zoom-level" = "THUNAR_ZOOM_LEVEL_38_PERCENT";
        "last-details-view-fixed-columns" = false;
        "last-details-view-column-widths" = "50,50,137,50,50,50,50,102,1145,50,50,55,107,61";

        "last-details-view-column-order" = "THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_MIME_TYPE,THUNAR_COLUMN_DATE_MODIFIED";
        "last-details-view-visible-columns" = "THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_MIME_TYPE,THUNAR_COLUMN_DATE_MODIFIED";
        "last-icon-view-zoom-level" = "THUNAR_ZOOM_LEVEL_100_PERCENT";

        "last-sort-column" = "THUNAR_COLUMN_NAME";
        "last-sort-order" = "GTK_SORT_ASCENDING";
        
        
        "last-separator-position" = 150;
        "shortcuts-icon-size" = "THUNAR_ICON_SIZE_32";
        "tree-icon-size" = "THUNAR_ICON_SIZE_24";


        "misc-single-click" = false;
        "misc-date-style" = "THUNAR_DATE_STYLE_YYYYMMDD";
        "misc-thumbnail-mode" = "THUNAR_THUMBNAIL_MODE_NEVER";
        "last-toolbar-items" = "menu:0,back:1,forward:1,open-parent:1,open-home:1,new-tab:0,new-window:0,toggle-split-view:0,undo:0,redo:0,zoom-out:0,zoom-in:0,zoom-reset:0,view-as-icons:0,view-as-detailed-list:0,view-as-compact-list:0,view-switcher:0,location-bar:1,reload:0,search:1,uca-action-0001:1,uca-action-0002:1";
        
      };
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
    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/turboboost no";
      ExecStop = "/run/current-system/sw/bin/turboboost yes";
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
    zip
    unzip
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

    # dev environment
    ansible
    nodejs_24
    go
    maven

    # kubernetes
    k9s
    kubernetes-helm

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


    # virtualization todo

    # all custom scripts & webapps
    scripts
    appicons


    # advanced desktop apps
    kdePackages.kdenlive
    onlyoffice-desktopeditors
    mlv-app
    drawio
    viber
    freac
    localsend
    avidemux
    postman

    # emulation
    # emulationstation-de
    # retroarch-full
    unstable.pcsx2
    # dolphin-emu
    cemu
  ];
  
  # nixpkgs.config.permittedInsecurePackages = [
  #   "freeimage-3.18.0-unstable-2024-04-18"
  #   "mbedtls-2.28.10"
  # ];

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
      ExecStart = "/run/current-system/sw/bin/firstboot-dockernet";
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
      ExecStart = "/run/current-system/sw/bin/firstboot-dockerbuildx";
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
  
  # GUI applications

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

  fonts.packages = with pkgs; [
    nerd-fonts.noto
    noto-fonts
  ];

  # # default terminal
  # xdg.terminal-exec.settings = {
  #   default = [
  #     "st.desktop"
  #   ];
  # };

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
    extraConfig = ''
      unload-module module-switch-on-connect

      #mic to caller
      load-module module-alsa-source device_id=loop,0,7 source_name=to-caller source_properties=device.description=to-caller rate=48000 
      set-source-volume to-caller 65536

      #sink/speaker that loops back to mic on device_id=loop,0,7 
      load-module module-alsa-sink device_id=loop,1,7 sink_name=to-caller-sink sink_properties=device.description=to-caller-sink rate=48000 
      set-sink-volume to-caller-sink 65536

      #dummy default sink and source for initial setup
      load-module module-alsa-source device_id=dummy,0,7 source_name=alsa_input.dummy-source source_properties=device.description=dummy-source rate=48000 
      set-source-volume alsa_input.dummy-source 65536

      load-module module-alsa-sink device_id=dummy,0,7 sink_name=alsa_output.dummy-sink sink_properties=device.description=dummy-sink rate=48000 
      set-sink-volume alsa_output.dummy-sink 65536


      # redirect from desktop to to-caller-sink and speakers
      load-module module-remap-sink sink_name=from-desktop sink_properties=device.description=from-desktop master=alsa_output.dummy-sink
      set-sink-volume from-desktop 62259
      set-sink-mute from-desktop 0

      # redirect from-caller to speaker only
      load-module module-remap-sink sink_name=from-caller sink_properties=device.description=from-caller master=alsa_output.dummy-sink
      set-sink-volume from-caller 62259

      set-sink-volume alsa_output.dummy-sink 29486

      # redirect mic split
      load-module module-remap-source source_name=mic01-processed master=alsa_input.dummy-source master_channel_map="front-left" channel_map="mono" source_properties=device.description="mic01-processed"
      load-module module-remap-source source_name=mic02-processed master=alsa_input.dummy-source master_channel_map="front-right" channel_map="mono" source_properties=device.description="mic02-processed"

      set-default-sink from-desktop
      set-default-source mic01-processed
    '';
    daemon.config = {
      default-sample-rate = 48000;
      default-sample-format = "s16le";
      resample-method = "soxr-hq";
    };
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

}

