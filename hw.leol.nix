{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [
    "nouveau"
  ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      nvidiaBusId = "PCI:01:00.0";
      intelBusId = "PCI:00:02.0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];
  nixpkgs.config.nvidia.acceptLicense = true;

}
