{ pkgs, vars, sources, ... }:
{
  nixpkgs.overlays = [
    (
      final: prev: {
        scripts = final.callPackage ./scripts {
          sources = sources;
          vars = vars;
        };
      }
    )
  ];
}
