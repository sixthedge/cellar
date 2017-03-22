#!/bin/bash

BUILD='docker build -t prod/rails:5.0.1 .'

DOCKER_SRC=.
TMP_DOCKER=/tmp/prod-rails

# Platform/Totem Sources
BASE_DIR=../../../src
PF_SRC=$BASE_DIR/thinkspace
TM_SRC=$BASE_DIR/totem

PF_API=$PF_SRC/api
TM_API=$TM_SRC/api

PF_PKG=$PF_SRC/packages/opentbl/api
TM_PKG=$TM_SRC/packages/totem/api

PF_ABIL=$PF_SRC/ability
PF_GEMS=$PF_PKG/src/rails/gemfiles
PF_RAIL=$PF_PKG/src/rails/config
PF_CONF=$PF_PKG/opentbl.config.yml
TM_CONF=$TM_PKG/totem.config.yml

# Destinations
TMP_GEMS=$TMP_DOCKER/src/gemfiles
TMP_RAIL=$TMP_DOCKER/src/rails/config
TMP_CONF=$TMP_DOCKER/src/config_files
TMP_ABIL=$TMP_DOCKER/src/ability
TMP_PFAP=$TMP_DOCKER/src/platform
TMP_TMAP=$TMP_DOCKER/src/totem

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

cp -r $DOCKER_SRC  $TMP_DOCKER  # copy docker in /tmp to run from /tmp directory

mkdir -p $TMP_RAIL && cp -r $PF_RAIL/* $TMP_RAIL
mkdir -p $TMP_ABIL && cp -r $PF_ABIL/* $TMP_ABIL
mkdir -p $TMP_GEMS && cp -r $PF_GEMS/* $TMP_GEMS

mkdir -p $TMP_PFAP && cp -r $PF_API/* $TMP_PFAP
mkdir -p $TMP_TMAP && cp -r $TM_API/* $TMP_TMAP

mkdir -p $TMP_CONF && cp $PF_CONF $TMP_CONF
mkdir -p $TMP_CONF && cp $TM_CONF $TMP_CONF

# Run docker build from tmp directory
cd $TMP_DOCKER
echo
echo "<Rails> $BUILD"
echo
$BUILD

# Clean up /tmp
# rm -r $TMP_DOCKER
