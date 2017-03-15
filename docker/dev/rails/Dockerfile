# docker build -t dev/rails:5.0.1 .

FROM phusion/passenger-ruby23:0.9.19

ENV \
  APP_PATH='/home/app' \
  APP_NAME='orchid' \
  rvm_silence_path_mismatch_check_flag=1

ENV APP_FULL_PATH="$APP_PATH/$APP_NAME"

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

COPY init     /etc/my_init.d
COPY env      /etc/nginx/main.d
COPY app.conf /etc/nginx/sites-enabled/$APP_NAME.conf

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

# nginx: forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
# 	&& ln -sf /dev/stderr /var/log/nginx/error.log
