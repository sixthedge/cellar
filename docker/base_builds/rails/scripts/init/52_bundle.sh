#!/bin/bash

add_gemfiles() {
  files=$(ls $1/Gemfile*)
  gemfiles=($files)
  for file in "${gemfiles[@]}"
  do
    tput -Tscreen setaf 6; tput -Tscreen bold; echo "    + Adding gemfile ($file)"; tput -Tscreen sgr0
    cat $file >> $APP_GEMFILE
  done
}

APP_GEMFILE=$APP_FULL_PATH/Gemfile
SRC_GEMFILES=/src/gemfiles

if ! [ -d "$SRC_GEMFILES" ]; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "*** [ERROR] Bundle source gems ($SRC_GEMFILES) do not exist"; tput -Tscreen sgr0
  exit 1
fi

if ! [ -f "$APP_GEMFILE" ]; then
  tput -Tscreen setaf 1; tput -Tscreen bold; echo "*** [ERROR] Bundle Rails gemfile ($APP_GEMFILE) does not exist"; tput -Tscreen sgr0
  exit 1
fi

# Append gems
tput -Tscreen setaf 6; tput -Tscreen bold; echo "+++ Bundle Rails platform gems"; tput -Tscreen sgr0
add_gemfiles $SRC_GEMFILES
chown app:app $APP_GEMFILE

# Bundle --local
tput -Tscreen setaf 6; tput -Tscreen bold; echo "    + Running bundle install --local"; tput -Tscreen sgr0
/sbin/setuser app bundle install --local --quiet
