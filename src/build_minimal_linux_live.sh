#!/bin/bash
set -eou pipefail 

# bash 00_clean.sh
# bash 01_get_kernel.sh
# bash 02_build_kernel.sh
# bash 03_get_glibc.sh
# bash 04_build_glibc.sh
# bash 05_prepare_glibc.sh
# bash 06_get_busybox.sh
# bash 07_build_busybox.sh
bash 08_prepare_src.sh
bash 09_generate_rootfs.sh
bash 09b_overlay_to_rootfs.sh
bash 10_pack_rootfs.sh
# bash 11_get_syslinux.sh
# bash 12_generate_iso.sh
