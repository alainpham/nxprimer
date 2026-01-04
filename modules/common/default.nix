{ config, lib, pkgs, vars, nixStateVersion, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # fastboot
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
  environment.etc."NetworkManager/dnsmasq.d/vms".source = "/home/${vars.targetUserName}/virt/runtime/vms";

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

  ##################################################
  # disableturbo
  ##################################################
  systemd.services.disable-intel-turboboost = {
    enable = vars.disableTurboBoost;
    description = "disable-intel-turboboost";
    wantedBy = [ "sysinit.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      ExecStart = "${pkgs.scripts}/bin/turboboost no";
      ExecStop = "${pkgs.scripts}/bin/turboboost yes";
      RemainAfterExit = true;
    };
  };

  

}