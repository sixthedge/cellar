#!/bin/sh

CONFIG_SRC=/src/config
APP_ROOT=$APP_FULL_PATH

if ! [ -d "$APP_ROOT" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] RAILS ENV[APP_FULL_PATH] IS NOT A DIRECTORY"; tput -Tscreen sgr0
  env
  exit 1
fi

if [ -d "$CONFIG_SRC" ] ; then
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "+++ COPYING RAILS CONFIG FILES FROM ($CONFIG_SRC) TO ($APP_ROOT)"; tput -Tscreen sgr0
  cp -r $CONFIG_SRC $APP_ROOT
  chown -R app:app $APP_ROOT
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] RAILS CONFIG DIRCTORY ($CONFIG_SRC) DOES NOT EXIST"; tput -Tscreen sgr0
  exit 1
fi
