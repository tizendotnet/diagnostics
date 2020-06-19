#!/usr/bin/env bash
set -e

__CrossDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
__TIZEN_CROSSDIR="$__CrossDir/tizen"

if [[ -z "$ROOTFS_DIR" ]]; then
    echo "ROOTFS_DIR is not defined."
    exit 1;
fi

# Clean-up (TODO-Cleanup: We may already delete  $ROOTFS_DIR at ./cross/build-rootfs.sh.)
# hk0110
if [ -d "$ROOTFS_DIR" ]; then
    umount $ROOTFS_DIR/*
    rm -rf $ROOTFS_DIR
fi

TIZEN_TMP_DIR=$ROOTFS_DIR/tizen_tmp
mkdir -p $TIZEN_TMP_DIR

# Download files
echo ">>Start downloading files"
VERBOSE=1 $__CrossDir/tizen-fetch.sh $TIZEN_TMP_DIR
echo "<<Finish downloading files"

echo ">>Start constructing Tizen rootfs"
TIZEN_RPM_FILES=`ls $TIZEN_TMP_DIR/*.rpm`
cd $ROOTFS_DIR
for f in $TIZEN_RPM_FILES; do
    rpm2cpio $f  | cpio -idm --quiet
done
echo "<<Finish constructing Tizen rootfs"

# Cleanup tmp
rm -rf $TIZEN_TMP_DIR

# Configure Tizen rootfs
echo ">>Start configuring Tizen rootfs"
patch -p1 < $__TIZEN_CROSSDIR/tizen.patch
echo "<<Finish configuring Tizen rootfs"
