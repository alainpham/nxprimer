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

read -p "Do you want to format the disk? (y/n): " FORMAT_DISK

if [[ "$FORMAT_DISK" == "y" ]]; then
echo "Formatting the disk..."

$TARGETDISKPREFIX=""
lsblk
read -p "Enter target disk (e.g., /dev/sda): " TARGETDISK
read -p "Enter prefix of partition number (usually p for nvme empty for sdX): " TARGETDISKPREFIX
read -p "Enter EFI size in GiB: " EFI_GIB
read -p "Enter swap size in GiB (0 = no swap): " SWAP_GIB
read -p "Enter data partition size in GiB (0 = use existing data if it exists): " DATA_GIB

echo "Partitioning disk..."
parted -s "${TARGETDISK}" mklabel gpt
sleep 1

NEXT_PART=1
echo "Creating EFI parition..."
EFI_PART=$NEXT_PART
parted -s "${TARGETDISK}" mkpart primary fat32 1MiB ${EFI_GIB}GiB
parted -s "${TARGETDISK}" set 1 esp on
sleep 1

NEXT_PART=$(($NEXT_PART +1 ))
NEXT_START_GIB=$((0 + $EFI_GIB))

if [[ "$SWAP_GIB" -gt 0 ]]; then
    SWAP_PART=$NEXT_PART
    SWAP_START_GIB=$NEXT_START_GIB
    SWAP_END_GIB="$(($NEXT_START_GIB + $SWAP_GIB))"

    echo "Creating ${SWAP_GIB}GiB swap partition..."
    parted -s "${TARGETDISK}" mkpart primary linux-swap ${SWAP_START_GIB}GiB ${SWAP_END_GIB}GiB
    sleep 1

    NEXT_PART=$(($NEXT_PART +1 ))
    NEXT_START_GIB=$SWAP_END_GIB

fi


if [[ "$DATA_GIB" -gt 0 ]]; then
    DATA_PART=$NEXT_PART
    DATA_START_GIB=$NEXT_START_GIB
    DATA_END_GIB="$(($NEXT_START_GIB + $DATA_GIB))"

    echo "Creating ${DATA_GIB}GiB data partition..."
    parted -s "${TARGETDISK}" mkpart primary ext4 ${DATA_START_GIB}GiB ${DATA_END_GIB}GiB
    sleep 1

    NEXT_PART=$(($NEXT_PART +1 ))
    NEXT_START_GIB=$DATA_END_GIB
fi


# Root
ROOT_PART=$NEXT_PART
ROOT_START_GIB=$NEXT_START_GIB

echo "Creating Root parition..."
parted -s "${TARGETDISK}" mkpart primary ext4 ${ROOT_START_GIB}GiB 100%
sleep 1

# Formating
echo "Formatting filesystems..."

echo "EFI partition.."
mkfs.fat -F 32 ${TARGETDISK}${TARGETDISKPREFIX}${EFI_PART}
sleep 2
fatlabel ${TARGETDISK}${TARGETDISKPREFIX}${EFI_PART} BOOT

echo "Format and activate swap partition.."
if [[ "$SWAP_GIB" -gt 0 ]]; then
    mkswap -L SWAP "${TARGETDISK}${TARGETDISKPREFIX}${SWAP_PART}"
    swapon -L SWAP
fi

echo "Format data partition.."
if [[ "$DATA_GIB" -gt 0 ]]; then
    if blkid "${TARGETDISK}${TARGETDISKPREFIX}${DATA_PART}" >/dev/null 2>&1; then
        mkfs.ext4 -F "${TARGETDISK}${TARGETDISKPREFIX}${DATA_PART}" -L DATA
    else
        mkfs.ext4 "${TARGETDISK}${TARGETDISKPREFIX}${DATA_PART}" -L DATA
    fi
fi

if blkid "${TARGETDISK}${TARGETDISKPREFIX}${ROOT_PART}" >/dev/null 2>&1; then
    mkfs.ext4 -F "${TARGETDISK}${TARGETDISKPREFIX}${ROOT_PART}" -L ROOT
else
    mkfs.ext4 "${TARGETDISK}${TARGETDISKPREFIX}${ROOT_PART}" -L ROOT
fi
sleep 1

else
    echo "Disk formatting skipped. Don't forget to turn swap on if needed"
fi

echo "Mounting filesystems..."

echo "Mounting ROOT"
mount /dev/disk/by-label/ROOT /mnt

echo "Mounting BOOT"
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/BOOT /mnt/boot

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
