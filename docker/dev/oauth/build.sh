#!/bin/bash

BUILD='docker build -t dev/oauth:5.0.1 .'

DOCKER_SRC=.

BASE_DIR=../../../..

OAUTH_SRC=$BASE_DIR/totem-oauth

TMP_DOCKER=/tmp/prod-oauth
TMP_OAUTH=$TMP_DOCKER

if [ "$TMP_DOCKER" = "" ]; then
  echo "Variable TMP_DOCKER is blank."
  exit 1
fi

if ! [[ "$TMP_DOCKER" =~ ^\/tmp\/ ]]; then
  echo "$TMP_DOCKER does not start with /tmp/."
  exit 1
fi

if [ -d $TMP_DOCKER ]; then
  rm -rf $TMP_DOCKER
fi
mkdir -p $TMP_DOCKER/src

cp -r $DOCKER_SRC  $TMP_DOCKER
cp -r $OAUTH_SRC   $TMP_OAUTH

# Run docker build from tmp directory
cd $TMP_DOCKER
echo
echo "<Rails> $BUILD"
echo
$BUILD

# Clean up /tmp
# rm -r $TMP_DOCKER
