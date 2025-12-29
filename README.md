# Nix distro for work and co.

## Get hashes from latest git repos

```sh
gitrepos="
dotfilesgit|https://github.com/alainpham/dotfiles.git
dwmgit|https://github.com/alainpham/dwm-flexipatch.git
stgit|https://github.com/alainpham/st-flexipatch.git
dmenugit|https://github.com/alainpham/dmenu-flexipatch.git
slockgit|https://github.com/alainpham/slock-flexipatch.git
dwmblocksgit|https://github.com/alainpham/dwmblocks.git
"

for gitrepo in $(echo $gitrepos); do

entry="${gitrepo%%|*}"
url="${gitrepo##*|}"

echo -n "$entry - "
git ls-remote $url master
done
```

## Installation

```sh

cfdisk

export TARGETDISK=/dev/sda
# for VMS
export TARGETDISK=/dev/vda

mkfs.fat -F 32 ${TARGETDISK}1
fatlabel ${TARGETDISK}1 NIXBOOT
mkfs.ext4 ${TARGETDISK}2 -L NIXROOT

mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/NIXBOOT /mnt/boot

nixos-generate-config --root /mnt

ip link set enp1s0 down

nixos-install

nixos-enter --root /mnt -c 'passwd apham'

```

```sh
scp *.nix nxvm:/etc/nixos ; scp vars.nxvm.nix nxvm:/etc/nixos/vars.nix
```

## 


build iso

```sh
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=/etc/nixos/iso.nix
```

Next steps

 - fix syncthing script
 - modularise into different files for server docker kubernetes worstation emulation station
 - hardware encoding
 - auto install vscode plugins


# silence chime of macbook pro 2007

Remove the kernel-applied protection on the variable: 
```sh
sudo chattr -i /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82

sudo rm /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82
printf "\x07\x00\x00\x00\x00" > ~/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82
sudo cp ~/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82 /sys/firmware/efi/efivars
```



# lg15
```sh
mkfs.fat -F 32 /dev/nvme0n1p1
fatlabel /dev/nvme0n1p1 NIXBOOT
mkfs.ext4 /dev/nvme0n1p2 -L NIXROOT
mkfs.ext4 /dev/nvme0n1p3 -L NIXDATA

mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/data
mount -o umask=077 /dev/disk/by-label/NIXBOOT /mnt/boot
mount /dev/disk/by-label/NIXDATA /mnt/data

nixos-generate-config --root /mnt
cp configuration.nix /mnt/etc/nixos/configuration.nix
cp vars.lg15.nix /mnt/etc/nixos/vars.nix
cp hw.lg15.nix /mnt/etc/nixos/hw.nix

nixos-install --no-root-passwd

```