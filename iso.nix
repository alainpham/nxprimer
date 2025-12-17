{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # Import your real system config
    /etc/nixos/configuration.nix
  ];
  
  networking.networkmanager.enable = lib.mkForce false;

  # ISO-specific overrides
  boot.supportedFilesystems = lib.mkForce [ "ext4" "xfs" "btrfs" ];
  boot.loader.timeout = lib.mkForce 5;
  # Make sure the installer has tools
  environment.systemPackages = with pkgs; [
  ];

  system.includeBuildDependencies = true;
  
  # Prevent network downloads during install
  nix.settings.substituters = lib.mkForce [];
  nix.settings.trusted-public-keys = lib.mkForce [];

  # Faster boot
  documentation.enable = false;

  # Make root usable during install
  services.getty.autologinUser = lib.mkForce "root";
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

}
