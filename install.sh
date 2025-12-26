#!/bin/bash

export TARGET_USERNAME=${1:-apham}

lsblk

read -p "Enter target disk (e.g., /dev/sda): " TARGETDISK
read -p "Enter swap size in GiB (0 = no swap): " SWAP_GIB

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

select file in hw.*.nix; do
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



echo "Partitioning disk..."
parted -s "${TARGETDISK}" mklabel gpt
sleep 1

echo "Creating EFI parition..."
parted -s "${TARGETDISK}" mkpart primary fat32 1MiB 1GiB
parted -s "${TARGETDISK}" set 1 esp on
sleep 1

PART_START_ROOT="1GiB"

if [[ "$SWAP_GIB" -gt 0 ]]; then
    SWAP_END="$((1 + SWAP_GIB))GiB"

    echo "Creating ${SWAP_GIB}GiB swap partition..."
    parted -s "${TARGETDISK}" mkpart primary linux-swap 1GiB "${SWAP_END}"
    sleep 1

    PART_START_ROOT="${SWAP_END}"
    ROOT_PART=3
else
    echo "No swap partition will be created."
    ROOT_PART=2
fi


# Root
echo "Creating Root parition..."
parted -s "${TARGETDISK}" mkpart primary ext4 "${PART_START_ROOT}" 100%
sleep 1

# Formating
echo "Formatting filesystems..."
mkfs.fat -F 32 ${TARGETDISK}1
sleep 2
fatlabel ${TARGETDISK}1 NIXBOOT

if [[ "$SWAP_GIB" -gt 0 ]]; then
    mkswap "${TARGETDISK}2"
    swapon "${TARGETDISK}2"
fi

if blkid "${TARGETDISK}${ROOT_PART}" >/dev/null 2>&1; then
    mkfs.ext4 -F "${TARGETDISK}${ROOT_PART}" -L NIXROOT
else
    mkfs.ext4 "${TARGETDISK}${ROOT_PART}" -L NIXROOT
fi
sleep 1

echo "Mounting filesystems..."
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/NIXBOOT /mnt/boot

nixos-generate-config --root /mnt

cp configuration.nix /mnt/etc/nixos/configuration.nix
cp $TARGETVARS /mnt/etc/nixos/vars.nix
cp $TARGETHW /mnt/etc/nixos/hw.nix

nixos-install --no-root-passwd

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
