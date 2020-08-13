# Build phase
FROM docker.pkg.github.com/gowowcore/dockerfiles/base-build:latest as build

ARG CORE
ARG FAMILY=none
ARG PLAYERBOTS=0

ENV \
    CORE="${CORE}" \
    FAMILY="${FAMILY}" \
    PLAYERBOTS="${PLAYERBOTS}"

RUN /build.sh

# Handle ownerships
RUN \
    cd / && \
    chown -R 911:911 /src /app

# Resulting image phase
FROM docker.pkg.github.com/gowowcore/dockerfiles/base-prod:latest as prod

ARG CORE
ARG FAMILY=none
ARG GAMEBUILD=0

ENV \
    CORE="${CORE}" \
    FAMILY="${FAMILY}"

ENV \
    WORLDSERVER_NAME="GoWowCore-${CORE}" \
    WORLDSERVER_TZ="0" \
    WORLDSERVER_ICON="0" \
    WORLDSERVER_MINSECURITY="0" \
    WORLDSERVER_GAMEBUILD="${GAMEBUILD}"

COPY s6/ /
COPY --from=build /src /src
COPY --from=build /app /app
