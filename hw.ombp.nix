{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [
    "nouveau"
  ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
  };
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];
  nixpkgs.config.nvidia.acceptLicense = true;

}
