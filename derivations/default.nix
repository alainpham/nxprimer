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
      }
    )
  ];
}
