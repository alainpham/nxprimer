#!/bin/bash
lsblk

read -p "Enter target disk (e.g., /dev/sda): " TARGETDISK

echo "Available configuration files:"

select file in vars.*.nix; do
    if [[ -n "$file" ]]; then
        echo "You selected: $file"
        export TARGETVARS=$file
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

parted -s ${TARGETDISK} mklabel gpt
sleep 1

parted -s ${TARGETDISK} mkpart primary fat32 1MiB 1GiB
sleep 1

parted -s ${TARGETDISK} set 1 esp on
sleep 1

parted -s ${TARGETDISK} mkpart primary ext4 1GiB 100%
sleep 1

mkfs.fat -F 32 ${TARGETDISK}1
sleep 1

fatlabel ${TARGETDISK}1 NIXBOOT
sleep 1

mkfs.ext4 ${TARGETDISK}2 -L NIXROOT
sleep 1

mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/NIXBOOT /mnt/boot
sleep 1

nixos-generate-config --root /mnt

cp configuration.nix /mnt/etc/nixos/configuration.nix
cp $TARGETVARS /mnt/etc/nixos/vars.nix

cd /mnt/etc/nixos

nixos-install

nixos-enter --root /mnt -c 'passwd apham'
