FROM ubuntu:focal as build
## ashamanecore:7.3.5 - start
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
      clang cmake make gcc g++ \
      libmariadbclient-dev libmariadb-client-lgpl-dev-compat mariadb-server mariadb-client \
      libboost-all-dev \
      libssl-dev \
      libreadline-dev \
      libbz2-dev \
      zlib1g-dev \
      p7zip-full unzip \
      libpth20 \
      wget \
      patch \
      git && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100
## ashamanecore:7.3.5 - end

## ashamanecore:7.3.5 - start
RUN git clone --single-branch -b legion --depth 1 https://github.com/AshamaneProject/AshamaneCore.git /AshamaneCore
## ashamanecore:7.3.5 - end

## ashamanecore:7.3.5 - start
RUN mkdir /AshamaneCore/build
WORKDIR /AshamaneCore/build
## ashamanecore:7.3.5 - end

## ashamanecore:7.3.5 - start
RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/ac
RUN make -j $(nproc)
RUN make install
RUN cd /AshamaneCore && git rev-parse --short HEAD > /ac/.commit
RUN \
    export ADB_FILE=$(awk '/_FULL_DATABASE/{print $NF}' /AshamaneCore/revision_data.h.in.cmake | tr -d '"') && \
    export ADB_RELEASE=$(echo "${ADB_FILE}" | cut -d'_' -f3 | cut -d"." -f1) && \
    wget -q https://github.com/AshamaneProject/AshamaneCore/releases/download/ADB_${ADB_RELEASE}/ADB_${ADB_RELEASE}.zip \
      -O /tmp/adb.zip && \
    unzip ${ADB_FILE} -d /ac/bin/
RUN \
    cd / && \
    rm -R /AshamaneCore/build && \
    rm -R /AshamaneCore/.git
## ashamanecore:7.3.5 - end


FROM lsiobase/ubuntu:focal as prod
ENV \
    AC_AUTHSERVER="false" \
    AC_AUTHSERVER_CONFIGFILE="authserver.conf" \
    AC_AUTHSERVER_PORT="3724" \
    AC_WORLDSERVER="false" \
    AC_WORLDSERVER_SOAP="false" \
    AC_WORLDSERVER_SOAP_PORT="7878" \
    AC_WORLDSERVER_CONFIGFILE="worldserver.conf" \
    AC_WORLDSERVER_PORT="8085" \
    AC_WORLDSERVER_NAME="GoWowCore" \
    AC_WORLDSERVER_ADDRESS="127.0.0.1" \
    AC_WORLDSERVER_ICON="0" \
    AC_WORLDSERVER_TZ="0" \
    AC_WORLDSERVER_MINSECURITY="0" \
    AC_WORLDSERVER_GAMEBUILD="26972"

## ashamanecore:7.3.5 - start
COPY --from=build /ac /ac
COPY --from=build /AshamaneCore /AshamaneCore
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
    chown -R abc:abc /ac /AshamaneCore
COPY s6/ /
## ashamanecore:7.3.5 - end
