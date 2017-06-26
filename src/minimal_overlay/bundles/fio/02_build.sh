#!/bin/sh

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

cd $MAIN_SRC_DIR/work/overlay/fio

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d fio-*)

echo "Preparing fio work area. This may take a while..."
make clean -j $NUM_JOBS 2>/dev/null

rm -rf ../fio_installed

echo "Configuring fio..."
./configure \
  --prefix=$MAIN_SRC_DIR/work/overlay/fio/fio_installed

echo "Building fio..."
make -j $NUM_JOBS

echo "Installing fio..."
make install -j $NUM_JOBS

mkdir -p ../fio_installed/lib

# # Copy all dependent GLIBC libraries.
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libnsl.so.1 ../dropbear_installed/lib
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libnss_compat.so.2 ../dropbear_installed/lib
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libutil.so.1 ../dropbear_installed/lib
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libcrypt.so.1 ../dropbear_installed/lib

echo "Reducing fio size..."
strip -g \
  ../fio_installed/bin/*

cp -r \
  ../fio_installed/bin \
  $MAIN_SRC_DIR/work/src/minimal_overlay/rootfs

echo "fio has been installed."

cd $SRC_DIR

