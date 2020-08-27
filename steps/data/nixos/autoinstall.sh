#!/bin/bash

set -e
set -x

export http_proxy="%HTTP_PROXY%"
export https_proxy="$http_proxy"

DISK=/dev/vda
MNT=/mnt

# Format partition
echo "Partitioning disk..."
parted -s $DISK mklabel msdos
parted -s -a none $DISK mkpart primary 64s 100%
parted -s $DISK set 1 boot on

mkfs.ext4 ${DISK}1 -L System 
mkdir -p $MNT
mount ${DISK}1 $MNT

# TODO: why unset ???
#unset http_proxy
#unset https_proxy

echo "Install nixos..."
mkdir -p $MNT/etc/nixos

curl -sSL http://%LOCAL_IP%:%HTTP_PORT%/configuration.nix > $MNT/etc/nixos/configuration.nix
curl -sSL http://%LOCAL_IP%:%HTTP_PORT%/hardware-configuration.nix > $MNT/etc/nixos/hardware-configuration.nix

nixos-install --root $MNT

echo "Set root's passwd and populate system directories..."
#NOTE: nixos-enter implies creation and settlement of system directories if they are missing
nixos-enter --root $MNT -- /run/current-system/sw/bin/mkdir -p /tmp
#The following only set the root password in the installer.
nixos-enter --root $MNT -- echo -n "root:%PASSWORD%" | /run/current-system/sw/bin/chpasswd

sync
umount $MNT

systemctl poweroff
