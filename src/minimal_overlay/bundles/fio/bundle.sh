#!/bin/bash
set -ex

SRC_DIR=$(pwd)

time bash 01_get.sh
time bash 02_build.sh


cd $SRC_DIR
