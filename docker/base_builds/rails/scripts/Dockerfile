FROM base/rails/gems:5.0.1

COPY init /etc/my_init.d

# nginx: forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
# 	&& ln -sf /dev/stderr /var/log/nginx/error.log

LABEL description='Base Rails with gems and init scripts'
