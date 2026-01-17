{ pkgs, vars, sources, ... }:
{
  nixpkgs.overlays = [
    (
      final: prev: {

        osscripts = final.callPackage ./osscripts {
          sources = sources;
          vars = vars;
        };

        containerscripts = final.callPackage ./containerscripts {
          sources = sources;
          vars = vars;
        };

        vmscripts = final.callPackage ./vmscripts {
          sources = sources;
          vars = vars;
        };

        guiscripts = final.callPackage ./guiscripts {
          sources = sources;
          vars = vars;
        };

        gamingscripts = final.callPackage ./gamingscripts {
          sources = sources;
          vars = vars;
        };
        
        webapps = final.callPackage ./webapps {
          sources = sources;
          vars = vars;
        };

        iconspkg = final.callPackage ./iconspkg {
          sources = sources;
          vars = vars;
        };

        nvtop = final.callPackage ./nvtop {
          sources = sources;
          vars = vars;
        };

        estation = final.callPackage ./estation {
          sources = sources;
          vars = vars;
        };

        retroarchpkg = final.callPackage ./retroarchpkg {
          sources = sources;
          vars = vars;
        };

        retroarchcorespkg = final.callPackage ./retroarchcorespkg {
          sources = sources;
          vars = vars;
        };

        retroarchbiospkg = final.callPackage ./retroarchbiospkg {
          sources = sources;
          vars = vars;
        };

        retroarchappimage = final.callPackage ./retroarchappimage {
          sources = sources;
          vars = vars;
        };

        pcsx2biospkg = final.callPackage ./pcsx2biospkg {
          sources = sources;
          vars = vars;
        };

        gshorts = final.callPackage ./gshorts {
          sources = sources;
          vars = vars;
        };

        fhsrun = final.callPackage ./fhsrun {
          sources = sources;
          vars = vars;
        };

        decklinksdk = final.callPackage ./decklinksdk {
          sources = sources;
          vars = vars;
        };

        blackmagic-desktop-video =
          prev.blackmagic-desktop-video.overrideAttrs (old: {
            # version = "14.3";
            version = "12.9";

            src = sources.blackmagicdesktopvideosrc;
            postUnpack = "";
            installPhase = ''
              runHook preInstall
              mkdir -p $out/{bin,share/doc,lib/systemd/system}
              cp -r $src/usr/share/doc/desktopvideo $out/share/doc
              cp $src/usr/lib/*.so $out/lib
              cp $src/usr/lib/systemd/system/DesktopVideoHelper.service $out/lib/systemd/system
              cp $src/usr/lib/blackmagic/DesktopVideo/DesktopVideoHelper $out/bin/
              substituteInPlace $out/lib/systemd/system/DesktopVideoHelper.service \
                --replace-fail "/usr/lib/blackmagic/DesktopVideo/DesktopVideoHelper" "$out/bin/DesktopVideoHelper"
              runHook postInstall
            '';
          });

            
      }
    )
  ];
}
