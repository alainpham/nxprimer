#!/bin/bash
set -e

# Discover disks with no mounted partitions
echo "Scanning for available disks..."
CANDIDATE_DISKS=()
CANDIDATE_LABELS=()

while read -r name size type; do
    [ "$type" = "disk" ] || continue
    dev="/dev/$name"
    # Skip if any partition/fs on this device is currently mounted
    if lsblk -n -o MOUNTPOINT "$dev" 2>/dev/null | grep -qv '^[[:space:]]*$'; then
        continue
    fi
    CANDIDATE_DISKS+=("$dev")
    CANDIDATE_LABELS+=("$name  [$size]")
done < <(lsblk -d -n -o NAME,SIZE,TYPE -e 7,11)

if [ ${#CANDIDATE_DISKS[@]} -eq 0 ]; then
    echo "No unmounted disks found." >&2
    exit 1
fi

echo ""
echo "Available disks:"
for i in "${!CANDIDATE_LABELS[@]}"; do
    echo "  $((i+1))) ${CANDIDATE_LABELS[$i]}"
done
echo ""

while true; do
    read -p "Select disk [1-${#CANDIDATE_DISKS[@]}]: " SEL
    [[ "$SEL" =~ ^[0-9]+$ ]] && [ "$SEL" -ge 1 ] && [ "$SEL" -le "${#CANDIDATE_DISKS[@]}" ] && break
    echo "Invalid selection."
done

TARGETDISK="${CANDIDATE_DISKS[$((SEL-1))]}"
echo "Selected: $TARGETDISK"
echo ""

# ---------------------------------------------------------------------------
# Scan existing partitions and LVM logical volumes on the selected disk
# ---------------------------------------------------------------------------
echo "Scanning existing layout on ${TARGETDISK}..."

declare -a ITEMS_DEV ITEMS_LABEL ITEMS_FSTYPE ITEMS_ACTION

# Physical partitions (skip LVM PVs — their LVs are scanned below)
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    type=$(echo "$line" | awk '{print $2}')
    [ "$type" = "part" ] || continue
    dev="/dev/$name"
    label=$(blkid -s LABEL -o value "$dev" 2>/dev/null)
    fstype=$(blkid -s TYPE  -o value "$dev" 2>/dev/null)

    [ "$fstype" = "LVM2_member" ] && continue

    if [ "$label" = "DATA" ]; then
        action="PRESERVE"
    elif [ -z "$fstype" ]; then
        action="SKIP (no filesystem)"
    else
        action="REFORMAT"
    fi

    ITEMS_DEV+=("$dev")
    ITEMS_LABEL+=("${label:-<none>}")
    ITEMS_FSTYPE+=("${fstype:-<unknown>}")
    ITEMS_ACTION+=("$action")
done < <(lsblk -n -o NAME,TYPE "${TARGETDISK}")

# LVM logical volumes on VGs that live on this disk
VG_NAME=$(pvs --noheadings -o pv_name,vg_name 2>/dev/null \
    | awk -v disk="${TARGETDISK}" '$1 ~ "^"disk {print $2}' \
    | head -1 | tr -d ' ')

if [ -n "$VG_NAME" ]; then
    while IFS= read -r lv_name; do
        lv_name=$(echo "$lv_name" | tr -d ' ')
        dev="/dev/${VG_NAME}/${lv_name}"
        label=$(blkid -s LABEL -o value "$dev" 2>/dev/null)
        fstype=$(blkid -s TYPE  -o value "$dev" 2>/dev/null)

        if [ "$label" = "DATA" ]; then
            action="PRESERVE"
        elif [ -z "$fstype" ]; then
            action="SKIP (no filesystem)"
        else
            action="REFORMAT"
        fi

        ITEMS_DEV+=("$dev")
        ITEMS_LABEL+=("${label:-<none>}")
        ITEMS_FSTYPE+=("${fstype:-<unknown>}")
        ITEMS_ACTION+=("$action")
    done < <(lvs --noheadings -o lv_name "${VG_NAME}" 2>/dev/null)
fi

if [ ${#ITEMS_DEV[@]} -eq 0 ]; then
    echo "No formattable partitions or LVs found on ${TARGETDISK}." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Display layout and planned actions
# ---------------------------------------------------------------------------
echo ""
echo "=== Layout on ${TARGETDISK} ==="
printf "  %-35s %-12s %-12s %s\n" "Device" "Label" "FS Type" "Action"
printf "  %-35s %-12s %-12s %s\n" "------" "-----" "-------" "------"
for i in "${!ITEMS_DEV[@]}"; do
    printf "  %-35s %-12s %-12s %s\n" \
        "${ITEMS_DEV[$i]}" "${ITEMS_LABEL[$i]}" "${ITEMS_FSTYPE[$i]}" "${ITEMS_ACTION[$i]}"
done
echo ""

read -p "Proceed? All entries marked REFORMAT will be wiped. [yes/N]: " CONFIRM
[ "${CONFIRM}" = "yes" ] || { echo "Aborted."; exit 1; }

# ---------------------------------------------------------------------------
# Reformat each device according to its existing filesystem type
# ---------------------------------------------------------------------------
for i in "${!ITEMS_DEV[@]}"; do
    [ "${ITEMS_ACTION[$i]}" = "REFORMAT" ] || continue
    dev="${ITEMS_DEV[$i]}"
    label="${ITEMS_LABEL[$i]}"
    fstype="${ITEMS_FSTYPE[$i]}"

    echo ""
    echo "Reformatting ${dev}  (label=${label}, fstype=${fstype})..."
    case "$fstype" in
        vfat)
            mkfs.fat -F32 -n "${label}" "${dev}"
            ;;
        swap)
            mkswap -L "${label}" "${dev}"
            ;;
        ext4|ext3|ext2)
            mkfs.ext4 -F -L "${label}" "${dev}"
            ;;
        xfs)
            mkfs.xfs -f -L "${label}" "${dev}"
            ;;
        btrfs)
            mkfs.btrfs -f -L "${label}" "${dev}"
            ;;
        *)
            echo "  WARNING: unrecognised fstype '${fstype}' — skipping ${dev}" >&2
            ;;
    esac
done

echo ""
echo "=== Done ==="
for i in "${!ITEMS_DEV[@]}"; do
    [ "${ITEMS_ACTION[$i]}" = "PRESERVE" ] && echo "Preserved (DATA): ${ITEMS_DEV[$i]}"
done
