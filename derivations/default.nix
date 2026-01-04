{ pkgs, vars, sources, ... }:
{
  nixpkgs.overlays = [
    (
      self: super:
      {
        scripts = super.callPackage ./scripts {}; # path containing default.nix
      }
    )
  ];
}