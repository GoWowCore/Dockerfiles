# Build pdhase
FROM ubuntu:focal as build

ARG CORE
ARG FAMILY=none
ARG PLAYERBOTS=0

ENV \
    CORE="${CORE}" \
    FAMILY="${FAMILY}" \
    PLAYERBOTS="${PLAYERBOTS}"

COPY build/install.sh /install.sh
RUN /install.sh
COPY build/build.sh /build.sh
RUN /build.sh

# Handle ownerships
RUN \
    cd / && \
    chown -R 911:911 /src /app

# Resulting image phase
FROM lsiobase/ubuntu:focal as prod

ARG CORE
ARG FAMILY=none
ARG GAMEBULD=0

ENV \
    CORE="${CORE}" \
    FAMILY="${FAMILY}"

ENV \
    AUTHSERVER="false" \
    AUTHSERVER_CONFIGFILE="authserver.conf" \
    AUTHSERVER_ADDRESS="0.0.0.0" \
    AUTHSERVER_PORT="3724"

ENV \
    WORLDSERVER="false" \
    WORLDSERVER_CONFIGFILE="worldserver.conf" \
    WORLDSERVER_ADDRESS="0.0.0.0" \
    WORLDSERVER_PORT="8085"

ENV \
    WORLDSERVER_NAME="GoWowCore-${CORE}" \
    WORLDSERVER_TZ="0" \
    WORLDSERVER_ICON="0" \
    WORLDSERVER_MINSECURITY="0" \
    WORLDSERVER_GAMEBUILD="${GAMEBUILD}"

COPY --from=build /app /app
COPY --from=build /src /src
RUN \
    apt-get -y update && \
    apt-get -y install \
      screen \
      netcat \
      libmariadb3 mariadb-client libboost-all-dev libreadline8 \
      && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*
COPY s6/ /
