# docker build -t ember-cli/ember:2.8LTS .

FROM ember-cli/base/app:2.8LTS

COPY init .

RUN \
  rm -rf app && \
  rm -rf config && \
  rm -rf tests && \
  rm -rf vendor

CMD $APP_FULL_PATH/start.sh
