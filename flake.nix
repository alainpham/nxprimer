
{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:NixOS/nixpkgs/c8cfcd6ccd422e41cc631a0b73ed4d5a925c393d"; # temporary workaround for cups issue
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

        # custom derivations of various apps
        ./derivations

        # modularized configurations
        ./modules/common

        # home manager
        home-manager.nixosModules.home-manager
      ]
      ++ nixpkgs.lib.optional (vars.enableDev) ./modules/dev
      ++ nixpkgs.lib.optional (vars.enableContainers) ./modules/containers
      ++ nixpkgs.lib.optional (vars.enableVirtualization) ./modules/virtualization
      ++ nixpkgs.lib.optional (vars.enableGui) ./modules/gui
      ++ nixpkgs.lib.optional (vars.enableWorkstation) ./modules/workstation
      ++ nixpkgs.lib.optional (vars.enableGaming) ./modules/gaming
      ;
    };
  };
}