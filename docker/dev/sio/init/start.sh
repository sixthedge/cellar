#!/bin/sh

APP_ROOT=$APP_FULL_PATH
TOTEM_PKG=/src/totem
PLATFORM_PKG=/src/platform
NODE_SRC=/src/node
APP_JS=app.js
APP_JS_SRC=$NODE_SRC/$APP_JS

if ! [ -d "$APP_ROOT" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO ENV[APP_FULL_PATH] IS NOT A DIRECTORY"; tput -Tscreen sgr0
  env
  exit 1
fi

if ! [ -d "$NODE_SRC" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO NODE SOURCE DIRECTORY ($NODE_SRC) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi

if [ -f "$APP_JS_SRC" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "+++ COPYING SIO $APP_JS FROM ($NODE_SRC) TO ($APP_ROOT)"; tput -Tscreen sgr0
  cp $APP_JS_SRC $APP_ROOT
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO $APP_JS FILE IN ($APP_JS_SRC) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi

if [ -d "$TOTEM_PKG" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "+++ npm install totem socketio server from ($TOTEM_PKG)"; tput -Tscreen sgr0
  npm install $TOTEM_PKG --quiet
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO TOTEM SERVER DIRECTORY ($TOTEM_PKG) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi

if [ -d "$PLATFORM_PKG" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "+++ npm install platform socketio server from ($PLATFORM_PKG)"; tput -Tscreen sgr0
  npm install $PLATFORM_PKG --quiet
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO PLATFORM SERVER DIRECTORY ($PLATFORM_PKG) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi

if [ -f "$APP_JS" ] ; then
  tput -Tscreen setaf 4; tput -Tscreen bold; echo "*** SIO NODE_ENVIRONMENT=$NODE_ENVIRONMENT"; tput -Tscreen sgr0
  node $APP_JS
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] SIO NODE SCRIPT ($APP_JS) DOES NOT EXIST"; tput -Tscreen sgr0
  ls -l
  exit 1
fi
