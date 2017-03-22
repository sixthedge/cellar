#!/bin/bash
set -e

BUILD_DIR=$(pwd -P)

clear

echo "Build development images in $BUILD_DIR"

cd $BUILD_DIR/oauth;       ./build.sh
cd $BUILD_DIR/postgres;    ./build.sh
cd $BUILD_DIR/rails;       ./build.sh
cd $BUILD_DIR/redis;       ./build.sh
cd $BUILD_DIR/sio;         ./build.sh
