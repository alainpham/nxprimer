
{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:NixOS/nixpkgs/d9bc5c7dceb30d8d6fafa10aeb6aa8a48c218454"; # temporary workaround for cups issue
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }: 
  let
    vars = import ./vars.nix;
    sources = import ./sources.nix;
    nixStateVersion = "25.11"; # change this only on fresh installs
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit vars sources nixStateVersion;
      };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./hw.nix
        ./modules/common
        home-manager.nixosModules.home-manager
      ];
    };
  };
}