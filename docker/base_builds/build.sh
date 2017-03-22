#!/bin/bash
set -e

BUILD_DIR=$(pwd -P)

clear

echo "Build base images in $BUILD_DIR"

cd $BUILD_DIR/oauth/gems;    ./build.sh
cd $BUILD_DIR/oauth/scripts; ./build.sh

cd $BUILD_DIR/rails/gems;    ./build.sh
cd $BUILD_DIR/rails/scripts; ./build.sh

cd $BUILD_DIR/sio/packages;  ./build.sh
cd $BUILD_DIR/sio/scripts;   ./build.sh
