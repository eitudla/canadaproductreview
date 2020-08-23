FROM alpine

# Create user
RUN adduser -D -u 1000 -g 1000 -s /bin/sh www-data \
    && mkdir -p /var/www/code \
    && chown -R www-data:www-data /var/www/code

# Install tini - 'cause zombies - see: https://github.com/ochinchina/supervisord/issues/60
# (also pkill hack)
# https://github.com/krallin/tini
RUN apk add --no-cache --update tini

# Install a golang port of supervisord. Much smaller in filezie.
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/bin/supervisord

# Install nginx & gettext (envsubst)
# Create cachedir and fix permissions
RUN apk add --no-cache --update \
        tzdata \
        gettext \
        composer \
        bash \
        nano \
        nginx \
    && mkdir -p /var/cache/nginx \
    && mkdir -p /var/lib/nginx \
    && mkdir -p /var/tmp/nginx \
    && chown -R www-data:www-data \
        /var/cache/nginx \
        /var/lib/nginx \
        /var/tmp/nginx

# Install PHP/FPM + Modules
RUN apk add --no-cache --update \
        php7 \
        php7-curl \
        php7-zlib \
        php7-phar \
        php7-intl \
        php7-fpm \
        php7-tokenizer \
        php7-gd \
        php7-iconv \
        php7-json \
        php7-mbstring \
        php7-oauth \
        php7-opcache \
        php7-openssl \
        php7-pdo \
        php7-pdo_mysql \
        php7-sqlite3 \
        php7-session \
        php7-soap \
        php7-zip \
        php7-mysqli \
        php7-simplexml \
        php7-xmlwriter \
        php7-xml \
        php7-dom \
        php7-sqlite3 \
        php7-pdo_sqlite \
        php7-fileinfo \
        php7-pecl-redis

# Installing dependencies for WKHTMLTOPDF
# https://github.com/madnight/docker-alpine-wkhtmltopdf/issues/3
# WKHTML to PDF needs libssl1.0, but repo missing from latest Alpine image.
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.8/main' >> /etc/apk/repositories
RUN apk add --update --no-cache \
    libssl1.0 libcrypto1.0 libgcc libstdc++ libx11 glib libxrender libxext libintl \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family

# Runtime env vars are envstub'd into config during entrypoint
ENV SERVER_NAME="localhost"
ENV SERVER_ALIAS=""
ENV SERVER_ROOT=/var/www/code/webroot
ENV TIMEZONE="Asia/Manila"

# Alias defaults to empty, example usage:
# SERVER_ALIAS='www.example.com'

# NB: the CLI will inherit the default PHP ini so if you need different behaviour (e.g. memory limit), populate the below accordingly
COPY ./docker/nginx/confs/php.ini /etc/php7/php.ini
# COPY ./docker/nginx/confs/php-cli.ini /etc/php7/php-cli.ini

#COPY ./docker/nginx/.htpasswd /etc/nginx/.htpasswd
COPY ./docker/nginx/confs/supervisord.conf /supervisord.conf
COPY ./docker/nginx/confs/php-fpm-www.conf /etc/php7/php-fpm.d/www.conf
COPY ./docker/nginx/confs/nginx.conf /nginx.conf
COPY ./docker/nginx/docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker/nginx/stop-supervisor.sh /stop-supervisor.sh
COPY ./docker/nginx/crontab /etc/crontabs/root
COPY ./docker/nginx/wkhtmltopdf.gz /bin/wkhtmltopdf.gz
RUN gzip -d /bin/wkhtmltopdf.gz
COPY ./docker/nginx/confs/bashrc /root/.bashrc
COPY ./ /var/www/code

RUN chmod +x \
        /bin/wkhtmltopdf \
        /docker-entrypoint.sh \
        /stop-supervisor.sh

# Nginx on :80
EXPOSE 80
WORKDIR /var/www/code

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
