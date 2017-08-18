#!/bin/bash

set -e

fail() {
  echo "$@"
  exit 1
}

[ -n "$KAMELEON_DEBUG" ] && set -x

[ -n "$CHROOT_DIR" ] || fail "No CHROOT_DIR defined"
[ -n "$RELEASE" ] || fail "No RELEASE defined"

HOSTNAME=${HOSTNAME:-localhost}
LOCALES=${LOCALES:-POSIX C en_US}
LANG=${LANG:-en_US.UTF-8}
CURRENT_ARCH="$(uname -m)"
ARCH=${ARCH:-$CURRENT_ARCH}
DEB_ARCH=${DEB_ARCH:-$(dpkg --print-architecture)}
DEB_KERNEL_ARCH=${DEB_KERNEL_ARCH:-$DEB_ARCH}
DEB_MIRROR_URI=${DEB_MIRROR_URI:-http://ftp.fr.debian.net/debian/}

if [ -n "$PROXY" ]; then
  export http_proxy="http://$PROXY"
  export https_proxy="$http_proxy"
  export ftp_proxy="$http_proxy"
  export rsync_proxy="$http_proxy"
  export all_proxy="$http_proxy"
  export HTTP_PROXY="$http_proxy"
  export HTTPS_PROXY="$http_proxy"
  export FTP_PROXY="$http_proxy"
  export RSYNC_PROXY="$http_proxy"
  export ALL_PROXY="$http_proxy"
  export no_proxy="localhost,${PROXY%%:*},127.0.0.1,localaddress,.localdomain"
  export NO_PROXY="$no_proxy"
fi

if [ $CURRENT_ARCH == $ARCH ]; then
  debootstrap --arch=$DEB_ARCH --no-check-gpg ${VARIANT:+--variant=$VARIANT} ${PACKAGES:+--include="$PACKAGES"} $RELEASE $CHROOT_DIR $DEB_MIRROR_URI
  CHROOT_CMD="chroot $CHROOT_DIR"
else
  debootstrap --foreign --arch=$DEB_ARCH --no-check-gpg ${VARIANT:+--variant=$VARIANT} ${PACKAGES:+--include="$PACKAGES"} $RELEASE $CHROOT_DIR $DEB_MIRROR_URI
  cp /usr/bin/qemu-$ARCH-static $CHROOT_DIR/usr/bin/
  CHROOT_CMD="chroot $CHROOT_DIR /usr/bin/qemu-$ARCH-static /bin/bash"
  $CHROOT_CMD /debootstrap/debootstrap --second-stage
fi

#Setting Hostname, network and lang
echo $HOSTNAME >> $CHROOT_DIR/etc/hostname

# Configure network interfaces
cat > $CHROOT_DIR/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

echo LANG=$LANG > $CHROOT_DIR/etc/locale.conf

test -f $CHROOT_DIR/etc/mtab || cat /proc/mounts > $CHROOT_DIR/etc/mtab
cat /etc/resolv.conf > $CHROOT_DIR/etc/resolv.conf

# Configure locales
if [ -f $CHROOT_DIR/etc/locale.gen ]; then
  for l in $LOCALES; do
    sed -i -e "s/^#$l/$l/" $CHROOT_DIR/etc/locale.gen
  done
  $CHROOT_CMD /usr/sbin/locale-gen
fi
