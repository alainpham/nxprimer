#!/bin/bash
set -e

read -p "Enter target disk (e.g., /dev/sda): " TARGETDISK
read -p "Enter prefix of partition number (usually p for nvme empty for sdX): " TARGETDISKPREFIX
read -p "Enter EFI size in MiB: " EFI_MIB
read -p "Enter swap size in GiB (0 = no swap): " SWAP_GIB
read -p "Enter data partition size in GiB (0 = use existing data if it exists): " DATA_GIB

EFI_PART="${TARGETDISK}${TARGETDISKPREFIX}1"
SWAP_PART="${TARGETDISK}${TARGETDISKPREFIX}2"
LVM_PART="${TARGETDISK}${TARGETDISKPREFIX}3"

VG_NAME="vg0"
LV_ROOT="root"
LV_DATA="data"

echo ""
echo "=== Partition plan for ${TARGETDISK} ==="
echo "  EFI:  ${EFI_MIB} MiB  -> ${EFI_PART} (FAT32, label=BOOT)"
if [ "${SWAP_GIB}" -gt 0 ]; then
    echo "  Swap: ${SWAP_GIB} GiB  -> ${SWAP_PART} (label=SWAP)"
fi
echo "  LVM:  remaining       -> ${LVM_PART} (VG=${VG_NAME})"
echo "    LV root: remaining space (label=ROOT)"
if [ "${DATA_GIB}" -gt 0 ]; then
    echo "    LV data: ${DATA_GIB} GiB (label=DATA)"
fi
echo ""
read -p "Proceed? This will DESTROY data on ${TARGETDISK}. [yes/N]: " CONFIRM
[ "${CONFIRM}" = "yes" ] || { echo "Aborted."; exit 1; }

# Wipe and create new GPT partition table
sgdisk --zap-all "${TARGETDISK}"

# Partition numbering
PART_NUM=1
EFI_NUM=${PART_NUM}; PART_NUM=$((PART_NUM + 1))

if [ "${SWAP_GIB}" -gt 0 ]; then
    SWAP_NUM=${PART_NUM}; PART_NUM=$((PART_NUM + 1))
fi

LVM_NUM=${PART_NUM}

EFI_PART="${TARGETDISK}${TARGETDISKPREFIX}${EFI_NUM}"
LVM_PART="${TARGETDISK}${TARGETDISKPREFIX}${LVM_NUM}"
if [ "${SWAP_GIB}" -gt 0 ]; then
    SWAP_PART="${TARGETDISK}${TARGETDISKPREFIX}${SWAP_NUM}"
fi

# EFI partition
sgdisk -n "${EFI_NUM}:0:+${EFI_MIB}MiB" -t "${EFI_NUM}:ef00" -c "${EFI_NUM}:BOOT" "${TARGETDISK}"

# Swap partition
if [ "${SWAP_GIB}" -gt 0 ]; then
    sgdisk -n "${SWAP_NUM}:0:+${SWAP_GIB}GiB" -t "${SWAP_NUM}:8200" -c "${SWAP_NUM}:SWAP" "${TARGETDISK}"
fi

# LVM partition (remaining space)
sgdisk -n "${LVM_NUM}:0:0" -t "${LVM_NUM}:8e00" -c "${LVM_NUM}:LVM" "${TARGETDISK}"

# Format EFI
mkfs.fat -F32 -n BOOT "${EFI_PART}"

# Format swap
if [ "${SWAP_GIB}" -gt 0 ]; then
    mkswap -L SWAP "${SWAP_PART}"
fi

# Set up LVM
pvcreate "${LVM_PART}"
vgcreate "${VG_NAME}" "${LVM_PART}"

if [ "${DATA_GIB}" -gt 0 ]; then
    lvcreate -L "${DATA_GIB}G" -n "${LV_DATA}" "${VG_NAME}"
    mkfs.ext4 -L DATA "/dev/${VG_NAME}/${LV_DATA}"
    lvcreate -l 100%FREE -n "${LV_ROOT}" "${VG_NAME}"
else
    # Check if data LV already exists (e.g. reusing existing VG)
    if lvs "${VG_NAME}/${LV_DATA}" &>/dev/null; then
        echo "Reusing existing LV ${VG_NAME}/${LV_DATA}"
        lvcreate -l 100%FREE -n "${LV_ROOT}" "${VG_NAME}"
    else
        lvcreate -l 100%FREE -n "${LV_ROOT}" "${VG_NAME}"
    fi
fi

mkfs.ext4 -L ROOT "/dev/${VG_NAME}/${LV_ROOT}"

echo ""
echo "=== Done ==="
echo "EFI:  ${EFI_PART} -> /boot/efi  (FAT32, BOOT)"
[ "${SWAP_GIB}" -gt 0 ] && echo "Swap: ${SWAP_PART} (SWAP)"
echo "Root: /dev/${VG_NAME}/${LV_ROOT} (ROOT)"
[ "${DATA_GIB}" -gt 0 ] && echo "Data: /dev/${VG_NAME}/${LV_DATA} (DATA)"
