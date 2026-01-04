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
      }
    )
  ];
}
