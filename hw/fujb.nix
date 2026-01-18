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

  # decklink support
  hardware.decklink.enable = true;
  environment.extraOutputsToInstall = [ "dev" ];

  environment.systemPackages = with pkgs; [
    blackmagic-desktop-video # for blackmagic capture card
  ];

  programs.obs-studio.package = pkgs.obs-studio.override {
    decklinkSupport = true;
  };

}
