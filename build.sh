#!/usr/bin/env bash

ROOT_PROJECT=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
BUILD_PATH=${TARGET:-$PWD}/build
ROOTFS_PATH=${TARGET:-$PWD}/rootfs

trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        echo "** Exited"
        exit 1
}

if [ -z "$1" ]; then
  RECIPES=from_scratch/*.yaml
else
  RECIPES="$@"
fi
for r in $RECIPES; do
    name=$(basename $r .yaml)
    if [ -e "$ROOTFS_PATH/${name}.tar" -a -z "$FORCE" ]; then
      echo "$ROOTFS_PATH/${name}.tar already exists"
    else
        rm -rf $BUILD_PATH
        echo -e "===============================================================\nname"
        echo -e "==============================================================="
        (set -x; kameleon build $ROOT_PROJECT/$r --build-path \
                    $BUILD_PATH --script --enable-cache --cache-archive-compression=none --global=appliance_formats:tar)
        if [ $? -eq 0 ]; then
            mkdir -p $ROOTFS_PATH
            date=$(date +%Y%m%d%H%M%S)
            for f in *.tar; do
              mv -v $BUILD_PATH/$name/$f $ROOTFS_PATH/${f%.tar}-$date.tar
            done
        else
            echo "\n$name FAILED\n"
        fi
    fi
done


# Push images to kameleon website
# rsync -avh rootfs/ oar-docmaster.website:~/kameleon-doc/rootfs/x86_64
