{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.blacklistedKernelModules = [ ];

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  fileSystems = {
    "/media/m01" = {
      device = "/dev/disk/by-label/m01";
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };
    "/media/m02" = {
      device = "/dev/disk/by-label/m02";
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };
    "/media/m03" = {
      device = "/dev/disk/by-label/m03";
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };
  };
}
