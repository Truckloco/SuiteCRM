FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql mysqli zip opcache curl soap

RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./
COPY deprecated.php ./
COPY Api/ ./Api/
COPY lib/ ./lib/
COPY include/ ./include/
COPY custom/ ./custom/
COPY modules/ ./modules/

RUN composer install --no-dev --no-interaction --prefer-dist

COPY . .

RUN chown -R www-data:www-data /var/www/html

COPY ./docker/apache/suitecrm.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite 