{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ ];

  hardware.nvidia = {
    open = false;
    powerManagement.enable = false;
    prime = {
      nvidiaBusId = "PCI:01:00:0";
      intelBusId = "PCI:00:02:0";
      sync.enable = false;
      offload.enable = true;
      offload.enableOffloadCmd = config.hardware.nvidia.prime.offload.enable;
    };
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];  
  nixpkgs.config.nvidia.acceptLicense = true;

  hardware.graphics = {
    extraPackages = with pkgs; [
      vpl-gpu-rt
    ];
  };
}
