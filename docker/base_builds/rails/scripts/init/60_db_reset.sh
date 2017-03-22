#!/bin/sh

if [ "$APP_DB_SEED_DIR" = '' ]; then
  _SEED_DIR=none
else
  _SEED_DIR=$APP_DB_SEED_DIR
fi

if [ "$APP_DB_RESET" = 'true' ]; then
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "+++ Rails DB reset in seed directory ($_SEED_DIR)"; tput -Tscreen sgr0
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "    + DB name: ($APP_DB_NAME) username: ($APP_DB_USERNAME)"; tput -Tscreen sgr0
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "    + Seed config: ($APP_DB_SEED_CONFIG) ai: ($APP_DB_SEED_AI)"; tput -Tscreen sgr0
  /sbin/setuser app /usr/bin/rake db:drop db:create totem:db:reset[$_SEED_DIR] CONFIG=$APP_DB_SEED_CONFIG AI=$APP_DB_SEED_AI
else
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "--- No Rails DB reset"; tput -Tscreen sgr0
fi

exit 0
