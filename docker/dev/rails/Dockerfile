FROM base/rails/gems/scripts:5.0.1

COPY app.conf /etc/nginx/sites-enabled/$APP_NAME.conf

RUN chown -R --quiet app:app $APP_PATH
