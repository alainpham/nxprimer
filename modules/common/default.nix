{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # faster boot times
  boot.loader.timeout = 1;

  system.stateVersion = nixStateVersion;

  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "dnsmasq";

  environment.etc."NetworkManager/dnsmasq.d/dev.conf".text = ''
    #/etc/NetworkManager/dnsmasq.d/dev.conf
    local=/${vars.wildcardDomain}/
    address=/${vars.wildcardDomain}/172.18.0.1
  '';
  environment.homeBinInPath = true;
  # to be put specifically in vm
  # environment.etc."NetworkManager/dnsmasq.d/vms".source = "/home/${vars.targetUserName}/virt/runtime/vms";

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_GB.UTF-8";

  console = {
    font = "LatArCyrHeb-16";
    keyMap = vars.keyboardLayout;
  };

  services.openssh.enable = true;

  #  execute shebangs on NixOS that assume hard coded locations in locations like /bin or /usr/bin etc
  services.envfs.enable = true;

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

  ##################################################
  # passwordless sudo for users in wheel group
  ##################################################
  services.getty.autologinOnce = vars.automaticlogin;
  services.getty.autologinUser = vars.targetUserName;

  ##################################################
  # enable spice agent only when running in a VM
  ##################################################
  services.spice-vdagentd.enable = lib.elem "virtio_console" config.boot.initrd.kernelModules;

  ##################################################
  # numlock on ttys on boot
  ##################################################
  systemd.services.numLockOnTty = {
    wantedBy = lib.optionals (vars.numlockOnBoot) [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.mkForce (pkgs.writeShellScript "numLockOnTty" ''
        for tty in /dev/tty{1..6}; do
            ${pkgs.kbd}/bin/setleds -D +num < "$tty";
        done
      '');
    };
  };

  environment.loginShellInit = ''
    export TARGET_USERNAME=${vars.targetUserName}
    export KEYBOARD_LAYOUT=${vars.keyboardLayout}
    export KEYBOARD_MODEL=${vars.keyboardModel}
    export KEYBOARD_VARIANT=${vars.keyboardVariant}
    export WILDCARD_DOMAIN=${vars.wildcardDomain}
  '';

  users.users = {
    ${vars.targetUserName} = {
      isNormalUser = true;
      extraGroups = [ 
        "wheel"
        "networkmanager"
      ];
    };
  };

  ##################################################
  # disableturbo
  ##################################################
  systemd.services.disable-intel-turboboost = {
    enable = vars.disableTurboBoost;
    description = "disable-intel-turboboost";
    wantedBy = [ "sysinit.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      ExecStart = "${pkgs.osscripts}/bin/turboboost no";
      ExecStop = "${pkgs.osscripts}/bin/turboboost yes";
      RemainAfterExit = true;
    };
  };

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

  home-manager.users.${vars.targetUserName} = {
    home.stateVersion = nixStateVersion;
    programs.git = {
      enable = true;
    };
    programs.bash = { 
      enable = true;
    };
    home.activation = {
      ssh-key = lib.hm.dag.entryAfter ["writeBoundary"] ''
        sshkeyexists=$([ -f "$HOME/.ssh/id_"*".pub" ] && echo 1 || echo 0)

        if [ $sshkeyexists -eq 0 ]; then
            ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N  ""
        fi
      '';
    };

    home.file = {
      ".gitconfig" = { 
        source = "${sources.dotfilesgit}/home/.gitconfig"; 
        force = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
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
    stow

    osscripts
  ]; 

}