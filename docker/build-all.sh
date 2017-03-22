#!/bin/bash
set -e

BUILD_DIR=$(pwd -P)

clear

echo "Build ALL images in $BUILD_DIR"

cd $BUILD_DIR/base_builds;    ./build.sh
cd $BUILD_DIR/dev;            ./build.sh
cd $BUILD_DIR/prod;           ./build.sh
