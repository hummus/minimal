#!/bin/bash
set -eo pipefail

# TODO - this shell script file needs serios refactoring since right now it does
# too many things:
# 
# 1) Deal with 'src' copy.
# 2) Generate the 'overlay' software bundles.
# 3) Create proper overlay structure.
# 4) Prepare the actual ISO structure.
# 5) Generate the actual ISO image.
#
# Probably it's best to create separate shell scripts for each functionality. 

echo "*** GENERATE ISO BEGIN ***"

SRC_DIR=$(pwd)

# Save the kernel installation directory.
KERNEL_INSTALLED=$SRC_DIR/work/kernel/kernel_installed

# Find the Syslinux build directory.
cd work/syslinux
cd $(ls -d *)
WORK_SYSLINUX_DIR=$(pwd)
cd $SRC_DIR

# Remove the old ISO file if it exists.
rm -f minimal_linux_live.iso
echo "Old ISO image files has been removed."

# Remove the old ISO generation area if it exists.
echo "Removing old ISO image work area. This may take a while..."
rm -rf work/isoimage

# This is the root folder of the ISO image.
mkdir work/isoimage
echo "Prepared new ISO image work area."

# Read the 'COPY_SOURCE_ISO' property from '.config'
COPY_SOURCE_ISO="$(grep -i ^COPY_SOURCE_ISO .config | cut -f2 -d'=')"

if [ "$COPY_SOURCE_ISO" = "true" ] ; then
  # Copy all prepared source files and folders to '/src'. Note that the scripts
  # will not work there because you also need proper toolchain.
  cp -r work/src work/isoimage
  echo "Source files and folders have been copied to '/src'."
else
  echo "Source files and folders have been skipped."
fi

cd work/isoimage

# Now we copy the kernel.
cp $KERNEL_INSTALLED/kernel ./kernel.xz

# Now we copy the root file system.
cp ../rootfs.cpio.xz ./rootfs.xz

# Read the 'OVERLAY_TYPE' property from '.config'
OVERLAY_TYPE="$(grep -i ^OVERLAY_TYPE $SRC_DIR/.config | cut -f2 -d'=')"

# overlay doesnt work for kernel < 3.4.18
echo "Generating ISO image with no overlay structure..."

# Copy the precompiled files 'isolinux.bin' and 'ldlinux.c32' in the ISO image
# root folder.
cp $WORK_SYSLINUX_DIR/bios/core/isolinux.bin .
cp $WORK_SYSLINUX_DIR/bios/com32/elflink/ldlinux/ldlinux.c32 .

# Create the ISOLINUX configuration file.
echo 'default kernel.xz  initrd=rootfs.xz' > ./syslinux.cfg

# Create UEFI start script.
mkdir -p efi/boot
cat << CEOF > ./efi/boot/startup.nsh
echo -off
echo Minimal Linux Live is starting...
\\kernel.xz initrd=\\rootfs.xz
CEOF

# Now we generate the ISO image file.
genisoimage \
  -J \
  -r \
  -o ../minimal_linux_live.iso \
  -b isolinux.bin \
  -c boot.cat \
  -input-charset UTF-8 \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  ./

# Copy the ISO image to the root project folder.
cp ../minimal_linux_live.iso ../../

if [ "$(id -u)" = "0" ] ; then
  # Apply ownership back to original owner for all affected files.
  chown $(logname) ../../minimal_linux_live.iso
  chown $(logname) ../../work/minimal_linux_live.iso
  chown -R $(logname) .
  echo "Applied original ownership to all affected files and folders."
fi

cd $SRC_DIR

echo "*** GENERATE ISO END ***"

