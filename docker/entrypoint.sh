#!/usr/bin/env sh
set -e
cd /var/www/html

if [ -d storage ] && [ -d bootstrap/cache ]; then
  chown -R www-data:www-data storage bootstrap/cache || true
  chmod -R ug+rwX storage bootstrap/cache || true
fi

if [ ! -L public/storage ]; then
  php artisan storage:link || true
fi

exec "$@"
