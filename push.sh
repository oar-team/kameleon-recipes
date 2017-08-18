#!/bin/bash

ROOTFS_PATH=${TARGET:-$PWD}/rootfs

FILES="$@"
for f in ${FILES:-$ROOTFS_PATH/*.tar}; do
  echo "Compress $f (for progress, run \`killall -USR1 xz')..."
  xz --keep -9 --thread=0 $f && (echo "Checksum & send ${f}.xz in background..." && sha1sum ${f}.xz > ${f}.xz.sha1sum && scp ${f}.xz ${REMOTE:-kameleonbuilder@kameleon.lig}:incoming/ && rm ${f}.xz.* & )
done
wait
