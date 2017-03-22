FROM base/oauth/gems/scripts:5.0.1

COPY app.conf /etc/nginx/sites-enabled/$APP_NAME.conf

COPY totem-oauth .

RUN chown -R --quiet app:app $APP_PATH
