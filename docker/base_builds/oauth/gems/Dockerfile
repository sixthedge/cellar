FROM phusion/passenger-ruby23:0.9.19

ENV \
  APP_PATH='/home/app' \
  APP_NAME='orchid' \
  rvm_silence_path_mismatch_check_flag=1

ENV APP_FULL_PATH="$APP_PATH/$APP_NAME"

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

USER app

COPY Gemfile      $APP_PATH
COPY Gemfile.lock $APP_PATH

RUN \
  cd $APP_PATH && \
  gem install bundler && \
  bundle install

USER root

WORKDIR $APP_FULL_PATH

LABEL rails=5.0.1
LABEL description='Base Oauth Rails with bundled gems and new rails application'
