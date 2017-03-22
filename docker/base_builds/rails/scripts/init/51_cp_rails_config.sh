#!/bin/sh

RAILS_CONFIG_SRC=/src/rails/config
APP_ROOT=$APP_FULL_PATH

if ! [ -d "$APP_ROOT" ] ; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] Rails ENV[APP_FULL_PATH] is not a directory"; tput -Tscreen sgr0
  env
  exit 1
fi

if [ -d "$RAILS_CONFIG_SRC" ] ; then
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "+++ Copying Rails config files from ($RAILS_CONFIG_SRC) TO ($APP_ROOT)"; tput -Tscreen sgr0
  cp -r $RAILS_CONFIG_SRC $APP_ROOT
  chown -R app:app $APP_ROOT
else
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "[ERROR] Rails config directory ($RAILS_CONFIG_SRC) does not exist"; tput -Tscreen sgr0
  exit 1
fi
