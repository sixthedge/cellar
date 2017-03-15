# docker build -t ember-cli/base/app:2.8LTS .

FROM ember-cli/base:2.10.1

ENV APP_NAME orchid
ENV APP_FULL_PATH $APP_PATH/$APP_NAME

# ember new
RUN ember new $APP_NAME

WORKDIR $APP_FULL_PATH

# copy app and bower files
COPY app .

# install bower packages
RUN \
    bower cache clean && \
    rm -rf bower_components && \
    bower install

# install base-app node packages
RUN \
  npm cache clean && \
  npm uninstall --save-dev ember-data && \
  ember install --save-dev ember-data@2.8.1 && \
  ember install ember-engines@0.3.4 && \
  ember install ember-cli-coffeescript@1.15.0 && \
  ember install ember-cli-coffees6@0.4.1 && \
  ember install ember-cli-emblem@0.8.2-beta.2 && \
  ember install ember-cli-sass@5.6.0 && \
  ember install ember-cli-moment-shim@3.0.1 && \
  ember install ember-simple-auth@1.1.0 && \
  ember install ember-moment@6.1.0 && \
  ember install ember-changeset@1.2.2 && \
  ember install ember-changeset-validations@1.2.4 && \
  ember install ember-cli-document-title@0.3.3 && \
  ember install ember-i18n@4.5.0
