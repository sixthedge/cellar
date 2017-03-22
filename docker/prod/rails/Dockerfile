FROM base/rails/gems/scripts:5.0.1

COPY app.conf /etc/nginx/sites-enabled/$APP_NAME.conf

COPY src/gemfiles        /src/gemfiles
COPY src/rails/config    /src/rails/config
COPY src/ability         /src/ability
COPY src/config/platform /src/config/platform
COPY src/config/totem    /src/config/totem
COPY src/platform        /src/platform
COPY src/totem           /src/totem

RUN \
  chown -R --quiet app:app /src && \
  chown -R --quiet app:app $APP_PATH
