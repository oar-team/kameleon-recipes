#!/bin/bash

set -e

fail() {
  echo "$@"
  exit 1
}

export http_proxy=
export https_proxy="$http_proxy"
export ftp_proxy="$http_proxy"
export rsync_proxy="$http_proxy"
export all_proxy="$http_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$http_proxy"
export FTP_PROXY="$http_proxy"
export RSYNC_PROXY="$http_proxy"
export ALL_PROXY="$http_proxy"
export no_proxy="localhost,$(echo $http_proxy | tr ":" "\n" | head -n 1),127.0.0.1,localaddress,.localdomain"
export NO_PROXY="$no_proxy"
export PATH=/usr/bin:/usr/sbin:/bin:/sbin:$PATH


DISK=/dev/sda
MNT=/mnt
MIRROR="http://mir.archlinux.fr"
HOSTNAME="localhost"
TIMEZONE="UTC"
LOCALE="en_US.UTF-8 UTF-8"
PACKAGES="base mkinitcpio dhcpcd linux systemd-sysvcompat iputils net-tools syslinux openssh vim"

cd /tmp/
curl -sSL https://projects.archlinux.org/arch-install-scripts.git/snapshot/arch-install-scripts-15.tar.gz > /tmp/arch-install-scripts-15.tar.gz
tar xvf /tmp/arch-install-scripts-15.tar.gz
cd arch-install-scripts-15
make
make install

# Format partition
echo "Partitioning disk..."
parted -s $DISK mklabel msdos
parted -s -a none $DISK mkpart primary 64s 100%
parted -s $DISK set 1 boot on

mkfs.ext4 ${DISK}1
mkdir -p $MNT
mount ${DISK}1 $MNT

# Bootstrap
curl -sSL https://raw.githubusercontent.com/tokland/arch-bootstrap/master/arch-bootstrap.sh > /tmp/arch-bootstrap.sh
bash /tmp/arch-bootstrap.sh -r "$MIRROR" $MNT

#Setting Hostname
echo $HOSTNAME >> $MNT/etc/hostname
cat /etc/resolv.conf > $MNT/etc/resolv.conf

ln -s /usr/share/zoneinfo/$TIMEZONE $MNT/etc/localtime
echo $LOCALE > $MNT/etc/locale.gen
arch-chroot $MNT locale-gen

# Configure pacman
haveged -w 1024
arch-chroot $MNT pacman-key --init
arch-chroot $MNT pacman-key --populate archlinux

# Update and install packages
arch-chroot $MNT pacman --noconfirm -Suy --force $PACKAGES

#Install Boot Loader
mkdir -p $MNT/boot/syslinux
extlinux --install $MNT/boot/syslinux

MBR_PATH=
PATHS=("/usr/share/syslinux/mbr.bin"
       "/usr/lib/bios/syslinux/mbr.bin"
       "/usr/lib/syslinux/bios/mbr.bin"
       "/usr/lib/extlinux/mbr.bin"
       "/usr/lib/syslinux/mbr.bin"
       "/usr/lib/syslinux/mbr/mbr.bin"
       "/usr/lib/EXTLINUX/mbr.bin")
for element in "${PATHS[@]}"
  do
  if [ -f "$element" ]; then
    MBR_PATH="$element"
    break
  fi
done

if [ "$MBR_PATH" == "" ]; then
    fail "unable to locate the extlinux mbr"
else
    dd if="$MBR_PATH" of="$DISK" bs=440  2>&1
fi

cat > $MNT/boot/syslinux/syslinux.cfg <<EOF
default archlinux
timeout 1

label archlinux
kernel ../vmlinuz-linux
initrd ../initramfs-linux.img
append root=UUID=`blkid -s UUID -o value /dev/sda1` rw net.ifnames=0
EOF


arch-chroot $MNT systemctl enable multi-user.target dhcpcd systemd-resolved systemd-networkd sshd
ln -sf /run/systemd/resolve/resolv.conf $MNT/etc/resolv.conf

sync
umount $MNT
sync

# force reboot
systemctl reboot
