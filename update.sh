sudo cp configuration.nix /etc/nixos
sudp cp sources.nix /etc/nixos
sudo cp vars/${HOSTNAME}.nix /etc/nixos/vars.nix
sudo cp flake.nix /etc/nixos/flake.nix
sudo cp -r modules /etc/nixos/
sudo cp -r derivations /etc/nixos/
sudo cp hw/${HOSTNAME}.nix /etc/nixos/hw.nix

sudo nixos-rebuild switch --flake /etc/nixos#nixos