#!/bin/bash
set -e
set -x
echo "libguestfs0     libguestfs/update-appliance     boolean false" | debconf-set-selections
echo "mdadm   mdadm/initrdstart       string  none" | debconf-set-selections

# To make I/O faster, we use a systemtap script that disables fsync.
# systemtap needs exactly the same kernel version for linux-headers and linux-image-dbg as currently installed.
# sometimes this requires adding a snapshot.d.o repository to get that version.
# finding the correct date is not easy. Usually you need to use http://snapshot.debian.org and trial and error.

# echo 'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20190813T053201Z/ buster/updates main' > /etc/apt/sources.list.d/snapshot-kernel.list

KERNEL=linux-image-$(uname -r)
VERSION=$(apt-cache policy $KERNEL | grep Installed: | awk '{print $2}')
ARCH=$(dpkg --print-architecture)
KERNEL_SHORT=$(uname -r | sed -re "s/^(.*)-[^-]*/\1/g")
apt-get update
apt-get install -y systemtap linux-image-$(uname -r)-dbg=$VERSION linux-headers-$(uname -r)=$VERSION linux-headers-$KERNEL_SHORT-common=$VERSION
/tmp/environments-recipes/tools/nofsync.stp </dev/null >/dev/null 2>&1 &

# if arm64 or ppc64, use backported package for libguestfs-tools. see #11432
if [ "$ARCH" = "arm64" -o "$ARCH" = "ppc64el" ]; then
	echo deb http://packages.grid5000.fr/deb/libguestfs-backport / > /etc/apt/sources.list.d/libguestfs-backport.list
fi
# install other dependencies
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends linux-headers-$(uname -r) netcat eatmydata libguestfs-tools gnupg-agent

mv /bin/gzip /bin/gzip.OLD
ln -s /usr/bin/pigz /bin/gzip

# Disable SMT on Power (necessary for qemu)
if [ "$ARCH" = "ppc64el" ]; then
	apt-get update && apt-get install -y powerpc-ibm-utils
	ppc64_cpu --smt=off
fi

cd /tmp
