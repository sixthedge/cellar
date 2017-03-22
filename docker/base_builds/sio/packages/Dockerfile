FROM node:6.10.0

ENV \
  APP_PATH='/home/app' \
  APP_NAME='orchid'

ENV APP_FULL_PATH $APP_PATH/$APP_NAME

RUN mkdir -p $APP_FULL_PATH

WORKDIR $APP_FULL_PATH

COPY package.json .

RUN \
  npm cache clean && \
  npm install --quiet

LABEL description='Base socket.io server with core packages'
