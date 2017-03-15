# docker build -t dev/postgres:9.5.6 .

FROM postgres:9.5.6

COPY ./init /docker-entrypoint-initdb.d/
