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

nixos-install

nixos-enter --root /mnt -c 'passwd apham'

```

```sh
scp *.nix nxvm:/etc/nixos ; scp vars.nxvm.nix nxvm:/etc/nixos/vars.nix
```

## 