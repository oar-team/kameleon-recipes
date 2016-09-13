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
for RECIPE_PATH in $RECIPES; do
    RECIPE_NAME=$(basename $RECIPE_PATH .yaml)
    if [ -e "$ROOTFS_PATH/${RECIPE_NAME}.tar" -a -z "$FORCE" ]; then
      echo "$ROOTFS_PATH/${RECIPE_NAME}.tar already exists"
    else
        rm -rf $BUILD_PATH
        echo -e "===============================================================\nRECIPE_NAME"
        echo -e "==============================================================="
        (set -x; kameleon build $ROOT_PROJECT/$RECIPE_PATH --build-path \
                    $BUILD_PATH --script --enable-cache --cache-archive-compression=none --global=appliance_formats:tar)
        if [ $? -eq 0 ]; then
            mkdir -p $ROOTFS_PATH
            mv $BUILD_PATH/$RECIPE_NAME/*.tar $ROOTFS_PATH/
        else
            echo "\n$RECIPE_NAME FAILED\n"
        fi
    fi
done


# Push images to kameleon website
# rsync -avh rootfs/ oar-docmaster.website:~/kameleon-doc/rootfs/x86_64
