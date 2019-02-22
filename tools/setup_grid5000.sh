#/bin/bash
set -e
set -x
echo "libguestfs0     libguestfs/update-appliance     boolean false" | debconf-set-selections
echo "mdadm   mdadm/initrdstart       string  none" | debconf-set-selections

# To make I/O faster, we use a systemtap script that disables fsync.
# systemtap needs exactly the same kernel version for linux-headers and linux-image-dbg as currently installed.
# sometimes this requires adding a snapshot.d.o repository to get that version.
# finding the correct date is not easy. Usually you need to use http://snapshot.debian.org and trial and error.
KERNEL=linux-image-$(uname -r)
VERSION=$(apt-cache policy $KERNEL | grep Installed: | awk '{print $2}')
echo 'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20181028T093335Z/ stretch-proposed-updates main' > /etc/apt/sources.list.d/snapshot-kernel.list
apt-get update
apt-get install -y systemtap linux-image-$(uname -r)-dbg=$VERSION linux-headers-$(uname -r)=$VERSION
/tmp/environments-recipes/tools/nofsync.stp </dev/null >/dev/null 2>&1 &

# install other dependencies
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git virtualbox linux-headers-amd64 socat qemu-utils ruby-dev ruby-childprocess polipo pigz netcat eatmydata libguestfs-tools dirmngr

gem install --no-ri --no-rdoc kameleon-builder
mv /bin/gzip /bin/gzip.OLD
ln -s /usr/bin/pigz /bin/gzip
cd /tmp

# workaround for gnupg bug when importing keys (http://bugs.debian.org/914944)
apt-get install -y gnupg/stretch-backports gnupg-agent/stretch-backports
