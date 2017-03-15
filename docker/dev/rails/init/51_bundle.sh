#!/bin/sh

if [ "$APP_BUNDLE" = 'true' ]; then
  tput -Tscreen setaf 6; tput -Tscreen bold; echo "+++ BUNDLE RAILS APP"; tput -Tscreen sgr0

  PLATFORM_GEMFILE=/src/gemfiles/platform
  TOTEM_GEMFILE=/src/gemfiles/totem
  APP_GEMFILE=$APP_FULL_PATH/Gemfile

  if [ -f "$PLATFORM_GEMFILE" ] ; then
    tput -Tscreen setaf 6; tput -Tscreen bold; echo "  +++ Adding platform gemfile: $PLATFORM_GEMFILE"; tput -Tscreen sgr0
    cat $PLATFORM_GEMFILE >> $APP_GEMFILE
  fi

  if [ -f "$PLATFORM_GEMFILE" ] ; then
    tput -Tscreen setaf 6; tput -Tscreen bold; echo "  +++ Adding totem gemfile: $PLATFORM_GEMFILE"; tput -Tscreen sgr0
    cat $TOTEM_GEMFILE >> $APP_GEMFILE
  fi

  chown app:app $APP_GEMFILE

  /sbin/setuser app bundle install --local --quiet

else

  tput -Tscreen setaf 6; tput -Tscreen bold; echo "--- NO BUNDLE RAILS APP"; tput -Tscreen sgr0

fi
