#!/bin/bash

# Check SSL, get one if don't have one already
if [ ! -f /etc/letsencrypt/live/catopus.education/fullchain.pem ]; then
    certbot --nginx -d catopus.education -d www.catopus.education --non-interactive --agree-tos --email your-email@example.com --redirect
fi

# Cron: update SSL every day
echo "0 0 * * * certbot renew --quiet && service nginx reload" >> /etc/crontab

# Start cron
service cron start

# Start Nginx
nginx -g "daemon off;"

cat /var/log/nginx/error.log
