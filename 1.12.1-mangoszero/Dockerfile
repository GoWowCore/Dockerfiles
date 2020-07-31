FROM ubuntu:focal as build
## mangoszero:1.12.1 - start
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
      clang cmake make gcc g++ \
      libmariadbclient-dev libmariadb-client-lgpl-dev-compat mariadb-server mariadb-client \
      libboost-all-dev \
      libssl-dev \
      libreadline-dev \
      libbz2-dev \
      p7zip-full \
      wget \
      patch \
      git && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100
## mangoszero:1.12.1 - end

## mangoszero:1.12.1 - start
RUN \
    mkdir /zero && \
    git clone --single-branch --recursive --depth 1 https://github.com/mangoszero/server.git /zero/server && \
    git clone --single-branch --recursive --depth 1 https://github.com/mangoszero/database.git /zero/db
## mangoszero:1.12.1 - end

## mangoszero:1.12.1 - start
RUN mkdir /zero/build
WORKDIR /zero/build
## mangoszero:1.12.1 - end

## mangoszero:1.12.1 - start
RUN cmake ../server/ -DCMAKE_INSTALL_PREFIX=/mangos -DCONF_INSTALL_DIR=/mangos/etc
RUN make -j $(nproc)
RUN make install
RUN cd /zero/server && git rev-parse --short HEAD > /mangos/.commit
RUN \
    cd / && \
    rm -R /zero/build && \
    rm -R /zero/server/.git /zero/db/.git
## mangoszero:1.12.1 - end


FROM lsiobase/ubuntu:focal as prod
ENV \
    M_REALMD="false" \
    M_REALMD_CONFIGFILE="realmd.conf" \
    M_REALMD_PORT="3724" \
    M_MANGOSD="false" \
    M_MANGOSD_SOAP="false" \
    M_MANGOSD_SOAP_PORT="7878" \
    M_MANGOSD_CONFIGFILE="mangosd.conf" \
    M_MANGOSD_PORT="8085" \
    M_MANGOSD_NAME="GoWowCore" \
    M_MANGOSD_ADDRESS="127.0.0.1" \
    M_MANGOSD_ICON="0" \
    M_MANGOSD_TZ="0" \
    M_MANGOSD_MINSECURITY="0" \
    M_MANGOSD_REALMBUILD="5875"

## mangoszero:1.12.1 - start
COPY --from=build /mangos /mangos
COPY --from=build /zero /zero
RUN \
    apt-get -y update && \
    apt-get -y install \
      libmariadb3 mariadb-client \
      openssl \
      screen \
      netcat \
      libboost-all-dev libreadline8 && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R abc:abc /mangos /zero
COPY s6/ /
## mangoszero:1.12.1 - end
