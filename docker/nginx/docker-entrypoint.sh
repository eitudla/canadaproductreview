#!/bin/sh -e

cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "$TIMEZONE" >  /etc/timezone

# jwilder/nginx-proxy support
SERVER_NAME=${VIRTUAL_HOST:-${SERVER_NAME:-localhost}}

envsubst '$SERVER_NAME $SERVER_ALIAS $SERVER_ROOT $LE_ROOT' < /nginx.conf > /etc/nginx/nginx.conf

chmod 777 /var/www/code/bin/cake
mkdir -p /var/www/code/tmp
mkdir -p /var/www/code/logs
mkdir -p /var/www/code/webroot/tmp
chown -R www-data:www-data /var/www/code/tmp
chown -R www-data:www-data  /var/www/code/logs
chown -R www-data:www-data  /var/www/code/webroot/tmp

# Make sure that any files created in tmp inherit the group of tmp
find /var/www/code/tmp -type d -exec chmod g+s {} +

# Run cron if set
if [ ! -z "$CRON" ]; then
    printenv >> /etc/profile #pass env vars to child processes (cron)
    crond
fi

supervisord -c /supervisord.conf
