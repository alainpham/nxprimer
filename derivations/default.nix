{ pkgs, vars, sources, ... }:
{
  nixpkgs.overlays = [
    (
      final: prev: {

        scripts = final.callPackage ./scripts {
          sources = sources;
          vars = vars;
        };

        nvtop = final.callPackage ./nvtop {
          sources = sources;
          vars = vars;
        };

        emustation = final.callPackage ./emustation {
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
      }
    )
  ];
}
