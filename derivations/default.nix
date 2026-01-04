{ pkgs, vars, sources, ... }:
{
  nixpkgs.overlays = [
    (
      final: prev: {
        scripts = final.callPackage ./scripts {
          sources = final.sources;
          vars = final.vars;
        };
      }
    )
  ];
}
