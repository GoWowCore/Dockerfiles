FROM lsiobase/alpine:3.12

RUN \
    apk add --no-cache \
      git curl \
      mysql-client \
      nginx php7-fpm \
      php7-json php7-xml php7-pdo php7-pdo_sqlite php7-sqlite3 php7-tokenizer \
      php7-curl php7-gd php7-mbstring php7-mysqli php7-openssl php7-soap php7-session php7-ctype \
    && git clone --single-branch --depth 1 https://github.com/FusionGen/FusionGen.git /app \
    && echo -e "<?php\nphpinfo();" > /app/info.php \
    && chown -R 911:911 /app

COPY s6/ /
