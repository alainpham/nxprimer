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
            version = "12.9";

            src = old.src.overrideAttrs (_: {
              outputHash = "sha256-oFzqoIgyOAPDopVOgh1fnFFOKqoJ0QSaGNgjOeeEcGE=";
            });
          });
      }
    )
  ];
}
