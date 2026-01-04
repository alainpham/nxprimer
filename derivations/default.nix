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
      }
    )
  ];
}
