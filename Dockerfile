FROM debian:stretch

RUN apt-get update && apt-get -y install libsqlite3-0 libexpat1 redis-server librrd8 logrotate libcurl3 libpcap0.8 libldap-2.4-2 libhiredis0.13 \
        libssl1.0.2 libmariadbclient18 lsb-release tar ethtool libcap2 bridge-utils libnetfilter-conntrack3 libzstd1 libmaxminddb0 \
        libradcli4 libjson-c3 libsnmp30 udev libzmq5 libcurl3-gnutls net-tools curl

# grab geoipupdate from the Debian contrib repository
RUN curl -Lo /tmp/geoipupdate_2.3.1-1_arm64.deb  http://ftp.us.debian.org/debian/pool/contrib/g/geoipupdate/geoipupdate_2.3.1-1_arm64.deb \
        && dpkg -i /tmp/geoipupdate_2.3.1-1_arm64.deb && rm /tmp/geoipupdate_2.3.1-1_arm64.deb

RUN curl -Lo /tmp/ntopng-data_4.1.200705_all.deb https://github.com/tusc/ntopng-udm/blob/master/packages/ntopng-data_4.1.200705_all.deb?raw=true \
        && curl -Lo /tmp/ntopng_4.1.200705-10698_arm64.deb https://github.com/tusc/ntopng-udm/blob/master/packages/ntopng_4.1.200705-10698_arm64.deb?raw=true \
        && dpkg -i /tmp/ntopng-data_4.1.200705_all.deb \
        && dpkg -i /tmp/ntopng_4.1.200705-10698_arm64.deb

# update ntop config file
# you can edit the file below if you want to change the default settings
RUN echo "-e" >> /etc/ntopng/ntopng.conf
RUN echo "-i=br0" >> /etc/ntopng/ntopng.conf
RUN echo "-n=1" >> /etc/ntopng/ntopng.conf
RUN echo "-W=3001" >> /etc/ntopng/ntopng.conf

# build startup script
# note The script below will instruct ntopng to listen to br0 by default.
# Change the -i parameter below if you want another interface
RUN echo "#!/bin/sh" > /startscript.sh
RUN echo "/etc/init.d/redis-server start" >> /startscript.sh
RUN echo "/usr/local/bin/ntopng /etc/ntopng/ntopng.conf" >> /startscript.sh
# Keep container running with the command below since we started
# just background services
RUN echo "tail -f /dev/null" >> /startscript.sh

RUN chmod +x /startscript.sh

ENTRYPOINT ["/startscript.sh"]
