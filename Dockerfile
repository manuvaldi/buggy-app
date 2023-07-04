FROM docker.io/library/ubuntu:lunar
# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y 
RUN apt-get -y install supervisor git apache2 libapache2-mod-php5 php5-mysql pwgen php-apc php5-mcrypt \
    || apt-get -y install supervisor git apache2 libapache2-mod-php php-mysql pwgen php-apcu php-mcrypt
RUN ln -s -f /bin/true /usr/bin/chfn && apt-get -y install default-mysql-server-core && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD ./lamp/start-apache2.sh /start-apache2.sh
ADD ./lamp/start-mysqld.sh /start-mysqld.sh
ADD ./lamp/run.sh /run.sh
RUN chmod 755 /*.sh
ADD ./lamp/my.cnf /etc/mysql/conf.d/my.cnf
ADD ./lamp/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD ./lamp/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
# ADD lamp/create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD ./lamp/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]

RUN apt-get update && apt-get install -y libgd-dev php5-gd
RUN rm -fr /app
COPY website /app
RUN chmod 777 /app/upload

COPY current.sql .
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD php.ini /etc/php5/apache2/php.ini
ADD php.ini /etc/php5/cli/php.ini
RUN sed -i 's/150/250/g' /etc/apache2/mods-available/mpm_worker.conf
RUN sed -i 's/150/250/g' /etc/apache2/mods-available/mpm_prefork.conf
RUN chmod 755 /*.sh
