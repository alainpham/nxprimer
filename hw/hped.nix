{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ ];

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-vaapi-driver
    ];
  };

}
