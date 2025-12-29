{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ ];

  hardware.nvidia = {
    open = false;
    powerManagement.enable = false;
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

  hardware.graphics = {
    extraPackages = with pkgs; [
      vpl-gpu-rt
    ];
  };
}
