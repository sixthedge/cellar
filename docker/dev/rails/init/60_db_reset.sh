#!/bin/sh

if [ "$APP_DB_SEED_DIR" = '' ]; then
  _SEED_DIR=none
else
  _SEED_DIR=$APP_DB_SEED_DIR
fi

if [ "$APP_DB_RESET" = 'true' ]; then
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "+++ RAILS APP DB RESET IN SEED DIR ($_SEED_DIR)"; tput -Tscreen sgr0
  /sbin/setuser app /usr/bin/rake db:drop db:create totem:db:reset[$_SEED_DIR] CONFIG=$APP_DB_SEED_CONFIG AI=$APP_DB_SEED_AI
else
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "--- NO RAILS APP DB RESET"; tput -Tscreen sgr0
fi
