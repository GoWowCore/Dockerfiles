#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install \
	build-essential cmake pkg-config \
	libmariadbclient-dev libmariadb-client-lgpl-dev-compat mariadb-server mariadb-client \
	libpth20 \
	libboost-all-dev \
	libssl-dev \
	libreadline-dev \
	libbz2-dev \
	zlib1g-dev \
	p7zip-full unzip \
	wget \
	patch \
	git
