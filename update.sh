sudo cp configuration.nix /etc/nixos
sudo cp vars.${HOSTNAME}.nix /etc/nixos/vars.nix
sudo nixos-rebuild switch