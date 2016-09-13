#!/bin/bash

ROOTFS_PATH=${TARGET:-$PWD}/rootfs

for f in $ROOTFS_PATH/*.tar; do
  echo "Compress $f (for progress, run \`killall -USR1 xz')..."
  xz --keep -9 --thread=0 $f && (echo "Send ${f}.xz in background..." && scp ${f}.xz ${REMOTE:-kameleonbuilder@kameleon.lig}:incoming/ && rm ${f}.xz & )
done
wait
