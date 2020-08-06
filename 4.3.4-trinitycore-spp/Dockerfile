FROM ubuntu:focal as build
## trinitycore:4.3.4 - start
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
## trinitycore:4.3.4 - end

## spp-npcbots:4.3.4 - start
RUN git clone --single-branch -b 4.3.4 --depth 1 https://github.com/conan513/SingleCore_TC.git /TrinityCore
## spp-npcbots:4.3.4 - end

## trinitycore:4.3.4 - start
RUN mkdir /TrinityCore/build
WORKDIR /TrinityCore/build
## trinitycore:4.3.4 - end

## trinitycore:4.3.4 - start
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/tc
RUN make -j $(nproc)
RUN make install
RUN cd /TrinityCore && git rev-parse --short HEAD > /tc/.commit
RUN \
    export TDB_FILE=$(awk '/_FULL_DATABASE/{print $NF}' /TrinityCore/revision_data.h.in.cmake | tr -d '"') && \
    export TDB_RELEASE=$(echo "${TDB_FILE}" | cut -d'_' -f4) && \
    wget -q https://github.com/TrinityCore/TrinityCore/releases/download/TDB${TDB_RELEASE}/${TDB_FILE%.*}.7z \
      -O /tmp/tdb.7z && \
    7z e -y /tmp/tdb.7z -o/tc/bin/ ${TDB_FILE}
RUN \
    cd / && \
    rm -R /TrinityCore/build && \
    rm -R /TrinityCore/.git
## trinitycore:4.3.4 - end


FROM lsiobase/ubuntu:focal as prod
ENV \
    TC_AUTHSERVER="false" \
    TC_AUTHSERVER_CONFIGFILE="authserver.conf" \
    TC_AUTHSERVER_PORT="3724" \
    TC_WORLDSERVER="false" \
    TC_WORLDSERVER_SOAP="false" \
    TC_WORLDSERVER_SOAP_PORT="7878" \
    TC_WORLDSERVER_CONFIGFILE="worldserver.conf" \
    TC_WORLDSERVER_PORT="8085" \
    TC_WORLDSERVER_NAME="GoWowCore" \
    TC_WORLDSERVER_ADDRESS="127.0.0.1" \
    TC_WORLDSERVER_ICON="0" \
    TC_WORLDSERVER_TZ="0" \
    TC_WORLDSERVER_MINSECURITY="0" \
    TC_WORLDSERVER_GAMEBUILD="12340"

## trinitycore:4.3.4 - start
COPY --from=build /tc /tc
COPY --from=build /TrinityCore /TrinityCore
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
    chown -R abc:abc /tc /TrinityCore
COPY s6/ /
## trinitycore:4.3.4 - end
