#!/bin/sh

SRC_DIR=$(pwd)

# Find the main source directory
cd ../../..
MAIN_SRC_DIR=$(pwd)
cd $SRC_DIR

# Grab everything after the '=' character.
DOWNLOAD_URL=$(grep -i FIO_SOURCE_URL $MAIN_SRC_DIR/.config | cut -f2 -d'=')

# Grab everything after the last '/' character.
ARCHIVE_FILE=${DOWNLOAD_URL##*/}

# Read the 'USE_LOCAL_SOURCE' property from '.config'
USE_LOCAL_SOURCE="$(grep -i USE_LOCAL_SOURCE $MAIN_SRC_DIR/.config | cut -f2 -d'=')"

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd $MAIN_SRC_DIR/source/overlay

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Downloading Dropbear source bundle file. The '-c' option allows the download to resume.
  echo "Downloading Links source bundle from $DOWNLOAD_URL"
  wget -c $DOWNLOAD_URL
else
  echo "Using local fio source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted Dropbear.
echo "Removing fio work area. This may take a while..."
rm -rf ../../work/overlay/fio
mkdir ../../work/overlay/fio

tar -xvf $ARCHIVE_FILE -C ../../work/overlay/fio

cd $SRC_DIR

# Grab everything after the '=' character.
DOWNLOAD_URL=$(grep -i ZLIB_SOURCE_URL $MAIN_SRC_DIR/.config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd $MAIN_SRC_DIR/source/overlay

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Downloading Dropbear source bundle file. The '-c' option allows the download to resume.
  echo "Downloading Links source bundle from $DOWNLOAD_URL"
  wget -c $DOWNLOAD_URL
else
  echo "Using local zlib source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted Dropbear.
echo "Removing zlib work area. This may take a while..."
rm -rf ../../work/overlay/zlib
mkdir ../../work/overlay/zlib

tar -xvf $ARCHIVE_FILE -C ../../work/overlay/zlib

cd $SRC_DIR

# Grab everything after the '=' character.
DOWNLOAD_URL=$(grep -i LIBAIO_SOURCE_URL $MAIN_SRC_DIR/.config | cut -f2 -d'=')
ARCHIVE_FILE=${DOWNLOAD_URL##*/}

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd $MAIN_SRC_DIR/source/overlay

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Downloading Dropbear source bundle file. The '-c' option allows the download to resume.
  echo "Downloading Links source bundle from $DOWNLOAD_URL"
  wget -c $DOWNLOAD_URL
else
  echo "Using local libaio source bundle $MAIN_SRC_DIR/source/overlay/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted Dropbear.
echo "Removing libaio work area. This may take a while..."
rm -rf ../../work/overlay/libaio
mkdir ../../work/overlay/libaio

tar -xvf $ARCHIVE_FILE -C ../../work/overlay/libaio

cd $SRC_DIR
