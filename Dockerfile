FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install curl jq -y

ENV DOCKER_REGISTRY_URL=
ENV DOCKER_REGISTRY_USER=
ENV DOCKER_REGISTRY_PASSWORD=
# DOCKER_IMAGE_CUTOFF_DAYS using days unit
ENV DOCKER_IMAGE_CUTOFF_DAYS=

WORKDIR /app

# Copy the script into the image
COPY cleanup.sh cleanup.sh
RUN chmod +x cleanup.sh
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh


CMD ["/app/entrypoint.sh"]

