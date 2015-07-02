# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.16

# Set correct environment variables.
ENV HOME /root

# main public direct
RUN sudo mkdir -p /data/www/public
ADD container-files/MongoTest.php /data/www/MongoTest.php
# this is where our main php file will be
ADD container-files/index.php /data/www/public/index.php

RUN rm -f /etc/service/sshd/down
# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-dockers init system.
CMD ["/sbin/my_init"]

# install add-apt-repository
RUN sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN sudo add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"
RUN sudo apt-get update && sudo apt-get upgrade -y
RUN sudo apt-get install -y software-properties-common python-software-properties \
    software-properties-common hhvm make git-core automake autoconf libtool gcc \
    hhvm-dev nginx

# hhvm config files
ADD container-files/server.ini /etc/hhvm/server.ini
ADD container-files/extra_php.ini /etc/hhvm/extra_php.ini

# mongodb extension
RUN cd /data; git clone git://github.com/mongodb/libbson.git; cd libbson/; ./autogen.sh; make; sudo make install;
RUN cd /data; git clone https://github.com/mongofill/mongofill-hhvm; cd mongofill-hhvm/; ./build.sh
RUN mkdir /data/hhvm_extensions; cp /data/mongofill-hhvm/mongo.so /data/hhvm_extensions/;

RUN cat /etc/hhvm/extra_php.ini >> /etc/hhvm/php.ini; rm /etc/hhvm/extra_php.ini

# nginx config
ADD container-files/nginx.conf /etc/nginx/nginx.conf

# set up init scripts
RUN mkdir /etc/service/nginx
ADD container-files/nginx.sh /etc/service/nginx/run
RUN chmod 700 /etc/service/nginx/run

RUN mkdir /etc/service/hhvm
ADD container-files/hhvm.sh /etc/service/hhvm/run
RUN chmod 700 /etc/service/hhvm/run

# set up nginx default site
ADD container-files/nginx-default /etc/nginx/sites-available/default

RUN sudo /usr/share/hhvm/install_fastcgi.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose port 80
EXPOSE 80

VOLUME ["/var/log"]
