{ config, lib, pkgs, stdenv... }:
let
  decklinkSdk = stdenv.mkDerivation rec {
    pname = "decklink-sdk";
    version = "15.3";

    buildInputs = [
      autoPatchelfHook
      libcxx
      libcxxabi
      libGL
      gcc
      unzip
    ];

    # yes, the below download function is an absolute mess.
    # blame blackmagicdesign.
    src = runCommandLocal "${pname}-${lib.versions.majorMinor version}-src.zip"
      rec {

        impureEnvVars = lib.fetchers.proxyImpureEnvVars;
        nativeBuildInputs = [ curl unzip ];
      } ''
      curl -L -o $out/sdk.zip "http://192.168.8.100:28000/blackmagic/Blackmagic_DeckLink_SDK_15.3.zip"
    '';

    installPhase = ''
      runHook preInstall

      echo $NIX_BUILD_TOP

      mkdir -p $out/include
      cp -r $NIX_BUILD_TOP/Blackmagic\ DeckLink\ SDK\ 12.5/Linux/include $out

      runHook postInstall
    '';
  }


  decklinkFfmpeg = pkgs.ffmpeg.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-nonfree" "--enable-decklink" ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
    buildInputs = oldAttrs.buildInputs ++ [
      pkgs.blackmagic-desktop-video
      decklinkSdk
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
    decklinkSdk
    decklinkFfmpeg 
  ];



}
