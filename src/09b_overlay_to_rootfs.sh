#!/bin/bash
set -eo pipefail

SRC_DIR=$(pwd)
# because overaly fs doesn't work in kernels < 3.4.18
# invoke the overlays but just put them in the regular busybox initrd

# Read the 'OVERLAY_BUNDLES' property from '.config'
OVERLAY_BUNDLES="$(grep -i ^OVERLAY_BUNDLES .config | cut -f2 -d'=')"

if [ ! "$OVERLAY_BUNDLES" = "" ] ; then
  echo "Generating additional overlay bundles. This may take a while..."
  cd minimal_overlay
  time bash -ex overlay_build.sh
  cd $SRC_DIR
else
  echo "Generation of additional overlay bundles has been skipped."
fi

mkdir -p work/rootfs/root/.ssh
cp minimal_overlay/rootfs/root/.ssh/authorized_keys work/rootfs/root/.ssh/authorized_keys
