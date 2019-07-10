#!/bin/bash

set -e

export http_proxy=
export https_proxy="$http_proxy"
export PASSWD=

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

unset http_proxy
unset https_proxy

echo "Install nixos..."
mkdir -p $MNT/etc/nixos
cp /tmp/configuration.nix $MNT/etc/nixos
cp /tmp/hardware-configuration.nix $MNT/etc/nixos

nixos-install --root $MNT --no-bootloader

echo "Set root's passwd and populate system directories..."
#NOTE: nixos-enter implies creation and settlement of system directories if they are missing
nixos-enter --root $MNT -- /run/current-system/sw/bin/mkdir -p /tmp
nixos-enter --root $MNT -- echo -n "root:$PASSWD" | /run/current-system/sw/bin/chpasswd

sync
umount $MNT
sync

systemctl poweroff
