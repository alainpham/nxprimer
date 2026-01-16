{ config, lib, pkgs, ... }:
let
 

  decklinkffmpeg = pkgs.ffmpeg.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-nonfree" "--enable-decklink" ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
    buildInputs = oldAttrs.buildInputs ++ [
      pkgs.blackmagic-desktop-video
      decklinksdk
    ];
    
    postFixup = ''
      addOpenGLRunpath ${placeholder "lib"}/lib/libavcodec.so
      addOpenGLRunpath ${placeholder "lib"}/lib/libavutil.so

      wrapProgram $bin/bin/ffmpeg \
        --prefix LD_LIBRARY_PATH : ${pkgs.blackmagic-desktop-video}/lib
    '';

  });
in
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
    decklinksdk
    decklinkffmpeg 
  ];



}
