#!/bin/bash

set -e

export http_proxy=
export https_proxy="$http_proxy"
export PASSWD=

DISK=/dev/sda
MNT=/mnt

# Format partition
echo "Partitioning disk..."
parted -s $DISK mklabel msdos
parted -s -a none $DISK mkpart primary 64s 100%
parted -s $DISK set 1 boot on

mkfs.ext4 ${DISK}1 -L nixos
mkdir -p $MNT
mount ${DISK}1 $MNT

echo "install nixos..."
mkdir -p $MNT/etc/nixos
cp /tmp/configuration.nix $MNT/etc/nixos
nixos-install --root $MNT <<EOF
$PASSWD
$PASSWD
EOF
sync
umount $MNT
sync

systemctl poweroff
