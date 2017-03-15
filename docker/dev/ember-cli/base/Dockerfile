# docker build -t ember-cli/base:2.10.1 .

FROM node:6.10.0

# ember-cli and live update
EXPOSE 4200 49152

ENV APP_PATH /home/app

RUN mkdir -p $APP_PATH

WORKDIR $APP_PATH

# install watchman
RUN \
  	git clone https://github.com/facebook/watchman.git && \
  	cd watchman && \
  	git checkout v3.5.0 && \
  	./autogen.sh && \
  	./configure && \
  	make && \
    make install

# # install yarn
# RUN \
#     apt-get update && apt-get install -y curl apt-transport-https && \
#     curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#     echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
#     apt-get update && apt-get install -y yarn

# install ember-cli and bower
RUN \
    npm cache clean && \
    npm install -g ember-cli@2.10.1 && \
    npm install -g bower@1.8.0

LABEL "ember-cli.version=2.10.1"
LABEL "bower.version=1.8.0"
LABEL "yarn.version=0.23.1"
LABEL "app_path=/home/app"
