#!/bin/bash

BUILD='docker build -t prod/sio:1.7.3 .'

DOCKER_SRC=.

BASE_DIR=../../../src

PLATFORM_SRC=$BASE_DIR/thinkspace/sio
TOTEM_SRC=$BASE_DIR/totem/sio
APP_JS_SRC=$PLATFORM_SRC/app.js

TMP_DOCKER=/tmp/prod-sio
TMP_PLATFORM=$TMP_DOCKER/src/platform
TMP_TOTEM=$TMP_DOCKER/src/totem
TMP_APP_JS=$TMP_DOCKER/src/node

if [ "$TMP_DOCKER" = "" ]; then
  echo "Variable TMP_DOCKER is blank."
  exit 1
fi

if ! [[ "$TMP_DOCKER" =~ ^\/tmp\/ ]]; then
  echo "$TMP_DOCKER does not start with /tmp/."
  exit 1
fi

if [ -d $TMP_DOCKER ]; then
  rm -r $TMP_DOCKER
fi
mkdir -p $TMP_DOCKER/src

cp -r $DOCKER_SRC   $TMP_DOCKER
cp -r $PLATFORM_SRC $TMP_PLATFORM
cp -r $TOTEM_SRC    $TMP_TOTEM
mkdir -p $TMP_APP_JS && cp $APP_JS_SRC $TMP_APP_JS

# Run docker build from tmp directory
cd $TMP_DOCKER
echo
echo "<Rails> $BUILD"
echo
$BUILD

# Clean up /tmp
# rm -r $TMP_DOCKER
