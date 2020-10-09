FROM php:7.2.19-fpm

ARG ALPINE_REPOSITORIES

RUN echo "deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib\ndeb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib\ndeb http://mirrors.aliyun.com/debian-security stretch/updates main\ndeb-src http://mirrors.aliyun.com/debian-security stretch/updates main\ndeb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib\ndeb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib\ndeb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib\ndeb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib\n" > /etc/apt/sources.list

RUN rm -rf /etc/apt/sources.list.d/buster.list

WORKDIR /tmp
USER root

RUN apt-get update

RUN apt-get install -y openssl

RUN apt-get install -y libssl-dev

RUN apt-get install -y zlib1g-dev

RUN apt-get install -y git

RUN curl -Ss https://mirrors.aliyun.com/composer/composer.phar >> composer.phar
RUN mv composer.phar /usr/local/bin/composer
RUN  chmod 777 /usr/local/bin/composer
