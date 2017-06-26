#!/bin/bash
set -eou pipefail 

bash -ex 00_clean.sh
bash -ex 01_get_kernel.sh
bash -ex 02_build_kernel.sh
bash -ex 03_get_glibc.sh
bash -ex 04_build_glibc.sh
bash -ex 05_prepare_glibc.sh
bash -ex 06_get_busybox.sh
bash -ex 07_build_busybox.sh
bash -ex 08_prepare_src.sh
bash -ex 09_generate_rootfs.sh
bash -ex 10_pack_rootfs.sh
bash -ex 11_get_syslinux.sh
bash -ex 12_generate_iso.sh
