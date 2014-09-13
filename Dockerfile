FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

MAINTAINER Matthias Glaub <magl@magl.net>

# update and install packages
RUN apt-get -qq update \
        && apt-get -qq upgrade -y \
        && apt-get -qq install -y apache2 php5 php5-mysql php5-sqlite php5-curl php5-intl php5-xdebug

# setting apache env vars
ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE $APACHE_RUN_DIR/apache2.pid
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

# redirect logs to stdout and stderr
RUN find "$APACHE_CONFDIR" -type f -exec sed -ri ' \
        s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
        s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
        ' '{}' ';'

# adding assets
ADD assets/ /assets/

EXPOSE 80

ENTRYPOINT ["/assets/entrypoint.sh"]
