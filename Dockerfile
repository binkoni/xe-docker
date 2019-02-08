FROM ubuntu:16.04

ENV PASSWORD xe
RUN unset HOME
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C

RUN apt update
RUN apt install --no-install-recommends -y git
RUN apt install --no-install-recommends -y ca-certificates
RUN apt install --no-install-recommends -y mariadb-server
RUN apt install --no-install-recommends -y apache2
RUN apt install --no-install-recommends -y php
RUN apt install --no-install-recommends -y libapache2-mod-php
RUN apt install --no-install-recommends -y php-mcrypt
RUN apt install --no-install-recommends -y php-mbstring
RUN apt install --no-install-recommends -y php-gd
RUN apt install --no-install-recommends -y php-curl
RUN apt install --no-install-recommends -y php-mysql
RUN apt install --no-install-recommends -y php-xml

RUN rm /var/www/html/*
RUN git clone https://github.com/xpressengine/xe-core /usr/src/xe
RUN echo "AllowOverride All" >> /usr/src/xe/.htaccess
RUN mkdir -p "/var/www/html/${SUBDIR}"

RUN mkdir /var/log/php
RUN chmod a+rwx /var/log/php

RUN chmod a+rw /var/log/apache2

RUN echo 'socket=/var/run/mysqld/mysqld.sock' >> /etc/mysql/my.cnf
RUN echo '[mysqld]' >> /etc/mysql/my.cnf
RUN echo 'sql_mode="NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES"' >> /etc/mysql/my.cnf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN a2enmod rewrite
RUN a2enmod headers

CMD service mysql start; mysql -u root -e "create database xe; create user 'xe'@'localhost'; grant all privileges on xe.* to 'xe'@'localhost' identified by '$PASSWORD';"; unset PASSWORD; cp -a /usr/src/xe/. "/var/www/html/${SUBDIR}"; chmod 707 "/var/www/html/${SUBDIR}"; exec apache2ctl -DFOREGROUND
