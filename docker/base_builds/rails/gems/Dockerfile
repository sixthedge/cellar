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

RUN \
  cd $APP_PATH && \
  rvm-exec default \
    rails new $APP_NAME \
      --api \
      --skip-keeps \
      --skip-bundle \
      --skip-listen \
      --skip-sprockets \
      --skip-javascript \
      --skip-gemfile \
      --skip-git \
      --skip-spring \
      --skip-action-cable \
      --skip-puma \
      --skip-turbolinks \
      --force \
      --quiet

WORKDIR $APP_FULL_PATH

RUN \
  rm -rf app && \
  rm -rf db && \
  rm -rf lib && \
  rm -rf test && \
  rm -rf vendor && \
  mv $APP_PATH/Gemfile $APP_FULL_PATH/Gemfile && \
  mv $APP_PATH/Gemfile.lock $APP_FULL_PATH/Gemfile.lock

LABEL rails=5.0.1
LABEL description='Base Rails with bundled gems and new rails application'
