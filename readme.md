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

nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable

nix-channel --update

nixos-install

nixos-enter --root /mnt -c 'passwd apham'

```


```sh
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update
```

```sh
scp *.nix nxvm:/etc/nixos ; scp vars.vm.nix nxvm:/etc/nixos/vars.nix
```
