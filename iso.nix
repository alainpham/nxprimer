{ config, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    /etc/nixos/configuration.nix
  ];

  system.stateVersion = config.system.stateVersion;
}