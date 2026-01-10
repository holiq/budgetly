FROM php:8.3-fpm-alpine AS phpbase

RUN apk add --no-cache \
    bash git unzip curl \
    icu-dev libzip-dev oniguruma-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    postgresql-dev

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && install-php-extensions \
    pdo_mysql pdo_pgsql pgsql bcmath mbstring intl zip opcache gd pcntl

RUN apk add --no-cache autoconf gcc g++ make \
 && pecl install redis \
 && docker-php-ext-enable redis \
 && apk del autoconf gcc g++ make

COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer


FROM phpbase AS phpdeps
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --prefer-dist --no-interaction --no-progress --no-dev --no-scripts


FROM node:22-alpine AS nodebuilder
WORKDIR /app

COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN \
  if [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable && pnpm i --frozen-lockfile; \
  elif [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  else npm install; fi

COPY . .

COPY --from=phpdeps /app/vendor ./vendor

RUN \
  if [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then pnpm run build; \
  elif [ -f yarn.lock ]; then yarn build; \
  else npm run build; fi


FROM phpbase AS appdist
WORKDIR /var/www/html

COPY . .
COPY --from=phpdeps /app/vendor ./vendor
COPY --from=nodebuilder /app/public/build ./public/build

RUN set -e; \
  mkdir -p bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views; \
  chmod -R 775 bootstrap/cache storage; \
  chown -R www-data:www-data bootstrap/cache storage || true; \
  if [ -f .env.example ]; then cp .env.example .env; else touch .env; fi; \
  composer dump-autoload -o --no-scripts; \
  php artisan package:discover --ansi; \
  rm -f .env


FROM phpbase AS php-runtime
WORKDIR /var/www/html
COPY --from=appdist /var/www/html /var/www/html

COPY docker/php.ini /usr/local/etc/php/conf.d/99-custom.ini
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm", "-F"]


FROM nginx:1.28-alpine AS nginx-runtime
WORKDIR /var/www/html

COPY --from=appdist /var/www/html/public /var/www/html/public
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
