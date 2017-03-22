#!/bin/bash

OUTFILE=/etc/nginx/main.d/app_env.conf

tput -Tscreen setaf 6; tput -Tscreen bold; echo "+++ Create Rails nginx environment variables in ($OUTFILE)"; tput -Tscreen sgr0

add_nginx_env() {
  var_list=`env | grep ^$1`
  evars=($var_list)
  for var in "${evars[@]}"
  do
    v=${var%%=*}
    if ! [ "$v" = "" ]; then
      # tput -Tscreen setaf 6; tput -Tscreen bold; echo "    + $v"; tput -Tscreen sgr0
      echo "env $v;" >> $OUTFILE
    fi
  done
}

add_nginx_env 'APP_'
add_nginx_env 'AWS_'
add_nginx_env 'DISCOURSE_'
add_nginx_env 'SMTP_'

echo "env rvm_silence_path_mismatch_check_flag;" >> $OUTFILE
