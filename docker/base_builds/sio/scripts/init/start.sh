#!/bin/sh

APP_ROOT=$APP_FULL_PATH
TOTEM_PKG=/src/totem
PLATFORM_PKG=/src/platform
NODE_SRC=/src/node
APP_JS=app.js
APP_JS_SRC=$NODE_SRC/$APP_JS

if ! [ -d "$APP_ROOT" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO ENV[APP_FULL_PATH] is not a directory"; tput -Tscreen sgr0
  env
  exit 1
fi

if ! [ -d "$NODE_SRC" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO node source directory ($NODE_SRC) does not exist"; tput -Tscreen sgr0
  exit 1
fi

if [ -f "$APP_JS_SRC" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "+++ Copying SIO $APP_JS from ($NODE_SRC) to ($APP_ROOT)"; tput -Tscreen sgr0
  cp $APP_JS_SRC $APP_ROOT
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO $APP_JS file in ($APP_JS_SRC) does not exist"; tput -Tscreen sgr0
  exit 1
fi

if [ -d "$TOTEM_PKG" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "+++ npm install totem socketio server from ($TOTEM_PKG)"; tput -Tscreen sgr0
  npm install $TOTEM_PKG --quiet
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO totem server directory ($TOTEM_PKG) does not exist"; tput -Tscreen sgr0
  exit 1
fi

if [ -d "$PLATFORM_PKG" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "+++ npm install platform socketio server from ($PLATFORM_PKG)"; tput -Tscreen sgr0
  npm install $PLATFORM_PKG --quiet
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO platform server directory ($PLATFORM_PKG) does not exist"; tput -Tscreen sgr0
  exit 1
fi

if [ -f "$APP_JS" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "*** SIO NODE_ENVIRONMENT=$NODE_ENVIRONMENT"; tput -Tscreen sgr0
  node $APP_JS
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO node script ($APP_JS) does not exist"; tput -Tscreen sgr0
  ls -l
  exit 1
fi
