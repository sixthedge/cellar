# docker build -t dev/socketio:1.7.3 .

FROM node:6.10.0

ENV \
  APP_PATH='/home/app' \
  APP_NAME='orchid'

ENV APP_FULL_PATH $APP_PATH/$APP_NAME

RUN mkdir -p $APP_FULL_PATH

WORKDIR $APP_FULL_PATH

COPY init .

RUN \
  npm cache clean && \
  npm install --quiet

CMD $APP_FULL_PATH/start.sh
