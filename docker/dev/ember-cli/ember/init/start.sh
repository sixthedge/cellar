#!/bin/sh

APP_ROOT=$APP_FULL_PATH
EMBER_SRC=/src/ember
PACKAGE_JSON=$EMBER_SRC/package.json
EMBER_CLI_BUILD_JS=$EMBER_SRC/ember-cli-build.js

if ! [ -d "$APP_ROOT" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] EMBER ENV[APP_FULL_PATH] IS NOT A DIRECTORY"; tput -Tscreen sgr0
  env
  exit 1
fi

if ! [ -d "$EMBER_SRC" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] EMBER SOURCE DIRECTORY ($EMBER_SRC) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi

if  [ -f "$PACKAGE_JSON" ] ; then
  tput -Tscreen setaf 5; tput -Tscreen bold; echo "+++ MERGING EMBER ($PACKAGE_JSON) TO ($APP_ROOT)"; tput -Tscreen sgr0
  node pkg-merge.js $PACKAGE_JSON
  if ! [ "$?" = '0' ]; then
    tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] FAILURE MERGING EMBER ($PACKAGE_JSON) WITH IMAGE (package.json)"; tput -Tscreen sgr0
    exit 1
  fi
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] EMBER ($PACKAGE_JSON) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi

if  [ -f "$EMBER_CLI_BUILD_JS" ] ; then
  tput -Tscreen setaf 5; tput -Tscreen bold; echo "+++ COPYING EMBER ($EMBER_CLI_BUILD_JS) TO ($APP_ROOT)"; tput -Tscreen sgr0
  cp $EMBER_CLI_BUILD_JS $APP_ROOT
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] EMBER ($EMBER_CLI_BUILD_JS) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi

tput -Tscreen setaf 5; tput -Tscreen bold; echo "*** Running 'ember server'"; tput -Tscreen sgr0
ember server
