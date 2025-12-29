{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ ];

  hardware.nvidia = {
    enable = true;
    open = false;
    powerManagement.enable = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = config.hardware.nvidia.prime.offload.enable;
      sync.enable = false;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];  
  nixpkgs.config.nvidia.acceptLicense = true;
}
