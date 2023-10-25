FROM php:8.1-cli-alpine3.18
RUN apk update && \
    apk add bash build-base gcc wget git autoconf libmcrypt-dev \
    g++ make openssl-dev \
    php81-openssl \
    php81-pdo_mysql \
    php81-mbstring
RUN apk add --no-cache oniguruma-dev zlib-dev libpng-dev libzip-dev sqlite pv

WORKDIR /app

RUN docker-php-ext-install pdo pdo_mysql mbstring bcmath gd zip opcache

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    mv composer.phar /usr/local/bin/composer && \
    php -r "unlink('composer-setup.php');"

ARG OPIGNO_VERSION=3.1.0
RUN wget https://bitbucket.org/opigno/opigno-composer/raw/${OPIGNO_VERSION}/composer.json -O composer.json
COPY upstream /app/upstream
COPY patches /app/patches

RUN export COMPOSER_ALLOW_SUPERUSER=1 && \
    composer config repositories.upstream path /app/upstream && \
    composer require --no-install --no-interaction --no-progress opigno/docker-cli-upstream && \
    composer install --dev --no-interaction --no-progress --optimize-autoloader

# @TODO: Improve PHP configuration settings.
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/70-uploads.ini && \
    echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/70-uploads.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/70-uploads.ini && \
    echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" >> /usr/local/etc/php/conf.d/99-custom-errors.ini && \
    echo "display_errors = Off" >> /usr/local/etc/php/conf.d/99-custom-errors.ini
WORKDIR /app/web
VOLUME /app

RUN ../vendor/bin/drush site-install opigno_lms --db-url=sqlite:///tmp/.ht.sqlite -y
RUN ../vendor/bin/drush upwd admin admin

# @TODO: Improve Drupal configuration settings.
RUN echo "\$settings['skip_permissions_hardening'] = TRUE;" >> /app/web/sites/default/settings.php && \
    echo "\$settings['trusted_host_patterns'] = array('^.*$');" >> /app/web/sites/default/settings.php && \
    echo "\$settings['file_private_path'] = '/app/private';" >> /app/web/sites/default/settings.php

RUN chown -R www-data:www-data /app/web 
RUN find /app/web -type d -exec chmod u=rwx,g=rx,o= '{}' \;
RUN find /app/web -type f -exec chmod u=rw,g=r,o= '{}' \; 
RUN chmod -R 0777 /app/web/sites/default/files
RUN [ -d /app/private ] || (mkdir -p /app/private; chown -R www-data:www-data /app/private; chmod -R 0777 /app/private)

EXPOSE 8888
CMD ["php", "-S", "0.0.0.0:8888", ".ht.router.php"]