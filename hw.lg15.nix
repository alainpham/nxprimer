{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ ];
  
  hardware.nvidia = {
    modesetting.enable = false;
    open = false;
    powerManagement.enable = false;
    prime = {
      offload.enable = false;
      offload.enableOffloadCmd = config.hardware.nvidia.prime.offload.enable;
      sync.enable = false;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };
  services.xserver.videoDrivers = [
    "nvidia"
  ];
  nixpkgs.config.nvidia.acceptLicense = true;

  hardware.graphics = {
    extraPackages = with pkgs; [
      vpl-gpu-rt
    ];
  };
}
