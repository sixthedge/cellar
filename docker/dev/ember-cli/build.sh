#!/bin/bash
set -e

BUILD_DIR=$(pwd -P)

echo "  <ember-cli> images in $BUILD_DIR"

# add: watchman; ember-cli; bower
cd $BUILD_DIR/base; ./build.sh

# create new ember app
# add: base packages
cd $BUILD_DIR/base-app; ./build.sh

# add: start.sh
cd $BUILD_DIR/ember; ./build.sh
