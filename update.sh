sudo cp configuration.nix /etc/nixos
sudo cp vars.${HOSTNAME}.nix /etc/nixos/vars.nix
sudo cp hw.${HOSTNAME}.nix /etc/nixos/hw.nix
sudo nixos-rebuild switch