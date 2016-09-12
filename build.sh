#!/usr/bin/env bash

ROOT_PROJECT=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
BUILD_PATH=/scratch/build
ROOTFS_PATH=/scratch/rootfs

trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        echo "** Exited"
        exit 1
}


for RECIPE_PATH in `ls from_scratch/*.yaml`; do
    RECIPE_NAME=$(basename $RECIPE_PATH .yaml)
    if [ ! -e "$ROOTFS_PATH/${RECIPE_NAME}.tar.xz" ]; then
        rm -rf $BUILD_PATH
        echo -e "===============================================================\nRECIPE_NAME"
        echo -e "==============================================================="
        (set -x; kameleon build $ROOT_PROJECT/$RECIPE_PATH --build-path \
                    $BUILD_PATH --script --enable-cache)
        if [ $? -eq 0 ]; then
            mkdir -p $ROOTFS_PATH
            mv $BUILD_PATH/$RECIPE_NAME/*.tar.{gz,xz} $ROOTFS_PATH/
        else
            echo "\n$RECIPE_NAME FAILED\n"
        fi
    fi
done


# Push images to kameleon website
# rsync -avh rootfs/ oar-docmaster.website:~/kameleon-doc/rootfs/x86_64
