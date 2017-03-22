FROM redis:3.2.8

# COPY ./init /docker-entrypoint-initdb.d/

# Add label to generate new image (e.g. not just reference official docker image)
# do can delete without deleting the official image and incase want to
# rename or add additional files later (e.g. init scripts).
LABEL description='Production redis'
