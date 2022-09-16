ARG PHP_VERSION
# please use ./docker_php generate image
FROM php:${PHP_VERSION}-fpm-alpine
USER root

ARG PHP_EXTENSIONS
ARG MORE_EXTENSION_INSTALLER
ARG ALPINE_REPOSITORIES

COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions

ENV EXTENSIONS=",${PHP_EXTENSIONS},"
ENV MC="-j$(nproc)"

RUN sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_REPOSITORIES}/g" /etc/apk/repositories \
    && apk add --no-cache autoconf g++ libtool make curl-dev libxml2-dev linux-headers
RUN apk add git && apk add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data

RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
  && php composer-setup.php && php -r "unlink('composer-setup.php');" \
    &&  mv composer.phar /usr/local/bin/composer\
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/;


RUN export MC="-j$(nproc)" \
    && chmod +x install.sh \
    && chmod +x "${MORE_EXTENSION_INSTALLER}" \
    && sh install.sh \
    && sh "${MORE_EXTENSION_INSTALLER}" \
    && rm -rf /tmp/extensions

WORKDIR /var/www/html
