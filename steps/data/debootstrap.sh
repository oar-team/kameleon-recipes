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


MNT=
RELEASE=
REPOSITORY="http://http.debian.net/debian/"
HOSTNAME="localhost"
LOCALES="POSIX C en_US fr_FR de_DE"
LANG="en_US.UTF-8"
CURRENT_ARCH="$(uname -m)"
ARCH="$CURRENT_ARCH"
DEBIAN_ARCH="$(dpkg --print-architecture)"
DEBIAN_KERNEL_ARCH="$DEBIAN_ARCH"
PACKAGES="less,locales,vim,openssh-server,linux-image-$DEBIAN_KERNEL_ARCH"


if [ $CURRENT_ARCH == $ARCH ]; then
  debootstrap --arch=$DEBIAN_ARCH --no-check-gpg --include="$PACKAGES" $RELEASE $MNT $REPOSITORY
  CHROOT_CMD="chroot $MNT"
else
  debootstrap --foreign --arch=$DEBIAN_ARCH --no-check-gpg --include="$PACKAGES" $RELEASE $MNT $REPOSITORY
  cp /usr/bin/qemu-$ARCH-static $MNT/usr/bin/
  CHROOT_CMD="chroot $MNT /usr/bin/qemu-$ARCH-static /bin/bash"
  $CHROOT_CMD /debootstrap/debootstrap --second-stage
fi

#Setting Hostname, network and lang
echo $HOSTNAME >> $MNT/etc/hostname

# Configure network interfaces
cat > $MNT/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

echo LANG=$LANG > $MNT/etc/locale.conf

test -f $MNT/etc/mtab || cat /proc/mounts > $MNT/etc/mtab
cat /etc/resolv.conf > $MNT/etc/resolv.conf

# Configure locales
if [ -f $MNT/etc/locale.gen ]; then
  for l in $LOCALES; do
    sed -i -e "s/^#$l/$l/" $MNT/etc/locale.gen
  done
fi
$CHROOT_CMD /usr/sbin/locale-gen
