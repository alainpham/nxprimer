#!/bin/bash

export TARGET_USERNAME=${1:-apham}

echo "Available configuration files:"

select file in vars/*.nix; do
    if [[ -n "$file" ]]; then
        echo "You selected: $file"
        export TARGETVARS=$file
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

select file in hw/*.nix; do
    if [[ -z $file ]]; then
        echo "No hardware selected"
        unset TARGETHW
        break
    else
        echo "You selected: $file"
        export TARGETHW="$file"
        break
    fi
done

echo "Mounting filesystems..."

echo "Mounting ROOT"
mount /dev/disk/by-label/ROOT /mnt

echo "Mounting BOOT"
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/BOOT /mnt/boot

if [ -e /dev/disk/by-label/SWAP ]; then
    swapon -L SWAP
fi

if [ -e /dev/disk/by-label/DATA ]; then
    echo "Mounting DATA"
    mkdir -p /mnt/data
    mount /dev/disk/by-label/DATA /mnt/data
fi


nixos-generate-config --root /mnt

cp configuration.nix /mnt/etc/nixos
cp sources.nix /mnt/etc/nixos
cp flake.nix /mnt/etc/nixos/flake.nix
cp -r modules /mnt/etc/nixos/
cp -r derivations /mnt/etc/nixos/
cp $TARGETVARS /mnt/etc/nixos/vars.nix
cp $TARGETHW /mnt/etc/nixos/hw.nix

cd /mnt/etc/nixos
nix flake update --extra-experimental-features nix-command --extra-experimental-features  flakes
# nix flake check --extra-experimental-features nix-command --extra-experimental-features  flakes
nixos-install --no-root-passwd --flake /mnt/etc/nixos#nixos

nixos-enter --root /mnt -c "passwd $TARGET_USERNAME"

cd /mnt/home/$TARGET_USERNAME/

git clone https://github.com/alainpham/nxprimer.git
git clone https://github.com/alainpham/dotfiles.git
git clone https://github.com/alainpham/lab.git

nixos-enter --root /mnt -c "chown -R $TARGET_USERNAME /home/$TARGET_USERNAME/nxprimer"
nixos-enter --root /mnt -c "chown -R $TARGET_USERNAME /home/$TARGET_USERNAME/dotfiles"
nixos-enter --root /mnt -c "chown -R $TARGET_USERNAME /home/$TARGET_USERNAME/lab"

cd /
sleep 2

umount -R /mnt
swapoff -a || true
echo "Installation complete."
