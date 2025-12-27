{ config, lib, pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_10;

  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [
    "nouveau"
  ];
  
  hardware.nvidia = {
    modesetting.enable = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
  };
  services.xserver.videoDrivers = [
    "nvidia"
  ];
  nixpkgs.config.nvidia.acceptLicense = true;

}
