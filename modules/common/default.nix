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
  environment.etc."NetworkManager/dnsmasq.d/vms".source = "/home/${vars.targetUserName}/virt/runtime/vms";
  environment.homeBinInPath = true;
}