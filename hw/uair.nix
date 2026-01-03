{ config, lib, pkgs, ... }:
{
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];
  
  nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
}
