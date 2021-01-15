FROM php:7.0-fpm

MAINTAINER Dragutin Cirkovic <dragutin@mcloud.rs>

RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && \
rm -rf /tmp/composer-setup.php

RUN apt-get update && \
apt-get install -y git unzip bash \
libfreetype6-dev \
libjpeg62-turbo-dev \
libmcrypt-dev \
libsqlite3-dev \
libcurl4-gnutls-dev \
nano \
net-tools \
bash-completion \
iputils-ping \
libc-client-dev \
libkrb5-dev && \
rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) mysqli iconv mcrypt gd pdo_mysql pcntl pdo_sqlite zip curl bcmath opcache mbstring gd && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
docker-php-ext-enable iconv mcrypt gd pdo_mysql pcntl pdo_sqlite zip curl bcmath opcache mbstring && \
apt-get autoremove -y

RUN cd /tmp \
&& curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
&& tar -xvvzf ioncube.tar.gz \
&& mv ioncube/ioncube_loader_lin_7.0.so /usr/local/lib/php/extensions/* \
&& rm -Rf ioncube.tar.gz ioncube \
&& echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/ioncube_loader_lin_7.0.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube_loader_lin_7.0.ini

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
sed -i 's/listen = 9000/listen = 0.0.0.0:9000/i' //usr/local/etc/php-fpm.d/zz-docker.conf && \
sed -i 's/pm.max_children = 5/pm.max_children = 50/i' //usr/local/etc/php-fpm.d/www.conf && \
sed -i 's/pm.start_servers = 2/pm.start_servers = 10/i' //usr/local/etc/php-fpm.d/www.conf && \
sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 10/i' //usr/local/etc/php-fpm.d/www.conf && \
sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 50/i' //usr/local/etc/php-fpm.d/www.conf && \
sed -i 's/;pm.process_idle_timeout = 10s;/pm.process_idle_timeout = 10s;/i' //usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www

CMD ["php-fpm"]
