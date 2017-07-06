#!/bin/sh
set -ex

SRC_DIR=$(pwd)

# Find the main source directory
cd ../../..
MAIN_SRC_DIR=$(pwd)
cd $SRC_DIR

# Read the 'JOB_FACTOR' property from '.config'
JOB_FACTOR="$(grep -i ^JOB_FACTOR $MAIN_SRC_DIR/.config | cut -f2 -d'=')"

# Read the 'CFLAGS' property from '.config'
# CFLAGS="$(grep -i ^CFLAGS $MAIN_SRC_DIR/.config | cut -f2 -d'=')"
CFLAGS=""

# Find the number of available CPU cores.
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)

# Calculate the number of 'make' jobs to be used later.
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))

# if [ ! -d $MAIN_SRC_DIR/work/glibc/glibc_prepared ] ; then
#   echo "Cannot continue - Dropbear SSH depends on GLIBC. Please buld GLIBC first."
#   exit 1
# fi

cd $MAIN_SRC_DIR/work/overlay/e2fsprogs

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d e2fsprogs-*)

echo "Preparing e2fsprogs work area. This may take a while..."
# make clean -j $NUM_JOBS

rm -rf ../e2fsprogs_installed

echo "Configuring e2fsprogs..."
./configure \
  --prefix=$MAIN_SRC_DIR/work/overlay/e2fsprogs/e2fsprogs_installed

echo "Building e2fsprogs..."
make -j $NUM_JOBS

echo "Installing e2fsprogs..."
make install -j $NUM_JOBS

mkdir -p ../e2fsprogs_installed/lib
# # Copy all dependent GLIBC libraries.
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/librt.so.1 ../fio_installed/lib
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libm.so.6 ../fio_installed/lib
cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libpthread.so.0 ../e2fsprogs_installed/lib
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libdl.so.2 ../fio_installed/lib

cd $MAIN_SRC_DIR/work/overlay/e2fsprogs

echo "Reducing e2fsprogs size..."
rm -Rf e2fsprogs_installed/lib/pkgconfig
strip -g \
  e2fsprogs_installed/sbin/badblocks

cp -r \
  e2fsprogs_installed/sbin/badblocks \
  $MAIN_SRC_DIR/work/rootfs/sbin/

echo "e2fsprogs has been installed."