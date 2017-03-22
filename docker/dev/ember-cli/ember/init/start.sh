#!/bin/sh

APP_ROOT=$APP_FULL_PATH
EMBER_SRC=/src/ember
PACKAGE_JSON=$EMBER_SRC/package.json
EMBER_CLI_BUILD_JS=$EMBER_SRC/ember-cli-build.js

if ! [ -d "$APP_ROOT" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] ember-cli ENV[APP_FULL_PATH] is not a directory"; tput -Tscreen sgr0
  env
  exit 1
fi

if ! [ -d "$EMBER_SRC" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] ember-cli source directory ($EMBER_SRC) does not exist"; tput -Tscreen sgr0
  exit 1
fi

if  [ -f "$PACKAGE_JSON" ] ; then
  tput -Tscreen setaf 5; tput -Tscreen bold; echo "+++ Merging ember-cli ($PACKAGE_JSON) into ($APP_ROOT/package.json)"; tput -Tscreen sgr0
  node pkg-merge.js $PACKAGE_JSON
  if ! [ "$?" = '0' ]; then
    tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] Failure merging ember-cli ($PACKAGE_JSON) with image (package.json)"; tput -Tscreen sgr0
    exit 1
  fi
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] ember-cli ($PACKAGE_JSON) does not exist"; tput -Tscreen sgr0
  exit 1
fi

if  [ -f "$EMBER_CLI_BUILD_JS" ] ; then
  tput -Tscreen setaf 5; tput -Tscreen bold; echo "+++ Copying ember-cli ($EMBER_CLI_BUILD_JS) to ($APP_ROOT)"; tput -Tscreen sgr0
  cp $EMBER_CLI_BUILD_JS $APP_ROOT
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] ember-cli ($EMBER_CLI_BUILD_JS) does not exist"; tput -Tscreen sgr0
  exit 1
fi

tput -Tscreen setaf 5; tput -Tscreen bold; echo "*** Running 'ember server'"; tput -Tscreen sgr0
ember server
