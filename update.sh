sudo cp configuration.nix /etc/nixos
sudo cp vars.${HOSTNAME}.nix /etc/nixos/vars.nix

if [ -f "hw.${HOSTNAME}.nix" ]; then
sudo cp hw.${HOSTNAME}.nix /etc/nixos/hw.nix
fi

sudo nixos-rebuild switch