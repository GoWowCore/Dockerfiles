# Derived from https://github.com/hwdsl2/docker-ipsec-vpn-server
FROM lsiobase/ubuntu:focal

ENV DOCKER_GEN_VERSION 0.7.4
ENV DOCKER_HOST unix:///var/run/docker.sock

RUN \
    apt-get update && \
    apt-get install -y \
      strongswan xl2tpd ppp iptables netcat mariadb-client dnsmasq \
    && \
    curl -s -L https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz -o /tmp/docker-gen.tar.gz && \
    tar xvzf /tmp/docker-gen.tar.gz && \
    mv docker-gen /usr/sbin/docker-gen && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/* /tmp/docker-gen.tar.gz

EXPOSE 500/udp 4500/udp

COPY s6/ /
