#!/bin/bash
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
cd $SRC_DIR
rm -rf ../fio_installed
mkdir -p ../fio_installed/lib

########
# zlib
cd $MAIN_SRC_DIR/work/overlay/zlib
cd $(ls -d zlib-*)

echo "Preparing zlib work area. This may take a while..."
echo "Configuring zlib..."

./configure \
  --prefix=$MAIN_SRC_DIR/work/overlay/fio/fio_installed

echo "Building fio.zlib..."
make -j $NUM_JOBS

echo "Installing fio.zlib..."
make install -j $NUM_JOBS

########
# libaio
cd $MAIN_SRC_DIR/work/overlay/libaio

cd $(ls -d libaio-*)

echo "Preparing libaio work area. This may take a while..."
make clean -j $NUM_JOBS 2>/dev/null

echo "Build and install fio.libaio..."
make -j $NUM_JOBS
make prefix=$MAIN_SRC_DIR/work/overlay/fio/fio_installed install

########
# fio
cd $MAIN_SRC_DIR/work/overlay/fio

# Change to the Dropbear source directory which ls finds, e.g. 'dropbear-2016.73'.
cd $(ls -d fio-*)

echo "Preparing fio work area. This may take a while..."
make clean -j $NUM_JOBS 2>/dev/null

echo "Configuring fio..."
./configure \
  --prefix=$MAIN_SRC_DIR/work/overlay/fio/fio_installed > configure.out

# these must be detected and enabled
cat configure.out | grep -E '^Linux AIO support' | grep -E 'yes$'
cat configure.out | grep -E '^zlib' | grep -E 'yes$'


echo "Building fio..."
make -j $NUM_JOBS

echo "Installing fio..."
make install -j $NUM_JOBS

mkdir -p ../fio_installed/lib
# # Copy all dependent GLIBC libraries.
cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/librt.so.1 ../fio_installed/lib
# cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libm.so.6 ../fio_installed/lib
cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libpthread.so.0 ../fio_installed/lib
cp $MAIN_SRC_DIR/work/glibc/glibc_prepared/lib/libdl.so.2 ../fio_installed/lib


cd $SRC_DIR


cd $MAIN_SRC_DIR/work/overlay/fio

echo "Reducing fio size..."
rm -Rf fio_installed/lib/pkgconfig
strip -g \
  fio_installed/bin/fio \
  fio_installed/lib/*

cp -r \
  fio_installed/bin \
  fio_installed/lib \
  $MAIN_SRC_DIR/work/rootfs

echo "fio has been installed."