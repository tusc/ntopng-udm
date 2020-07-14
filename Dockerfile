# necessary for running build from x86 environments
ADD qemu-aarch64-static /usr/bin

RUN apt-get update && apt-get --no-install-recommends -y install libsqlite3-0 libexpat1 redis-server librrd8 logrotate libcurl4 libpcap0.8 libldap-2.4-2 libhiredis0.14 \
        libssl1.1 libmariadbd19 lsb-release tar ethtool libcap2 bridge-utils libnetfilter-conntrack3 libzstd1 libmaxminddb0 \
        libradcli4 libjson-c3 libsnmp30 udev libzmq5 libcurl3-gnutls net-tools curl procps && rm -rf /var/lib/apt/lists/*

# grab geoipupdate from the Debian contrib repository
RUN curl -Lo /tmp/geoipupdate_2.3.1-1_arm64.deb  http://ftp.us.debian.org/debian/pool/contrib/g/geoipupdate/geoipupdate_2.3.1-1_arm64.deb \
        && dpkg -i /tmp/geoipupdate_2.3.1-1_arm64.deb && rm /tmp/geoipupdate_2.3.1-1_arm64.deb

COPY packages/*200711* /tmp/
RUN dpkg -i /tmp/ntopng-data_4.1.200711_all.deb /tmp/ntopng_4.1.200711-10754_arm64.deb && rm /tmp/ntop*.deb

#RUN curl -Lo /tmp/ntopng-data_4.1.200711_all.deb https://github.com/tusc/ntopng-udm/blob/master/packages/ntopng-data_4.1.200711_all.deb?raw=true \
#        && curl -Lo /tmp/ntopng_4.1.200711-10754_arm64.deb https://github.com/tusc/ntopng-udm/blob/master/packages/ntopng_4.1.200711-10754_arm64.deb?raw=true \
#        && dpkg -i /tmp/ntopng-data_4.1.200711_all.deb \
#        && dpkg -i /tmp/ntopng_4.1.200711-10754_arm64.deb

# update ntop config file
RUN echo "-e" >> /etc/ntopng/ntopng.conf
RUN echo "-i=br0" >> /etc/ntopng/ntopng.conf
RUN echo "-n=1" >> /etc/ntopng/ntopng.conf
RUN echo "-W=3001" >> /etc/ntopng/ntopng.conf

# build startup script
# note The script below will instruct ntopng to listen to br0 by default.
# Change the -i parameter below if you want another interface
RUN echo "#!/bin/bash" > /startscript.sh
RUN echo "/etc/init.d/redis-server start" >> /startscript.sh
# check if GeoIP.conf is populated. If so run geoipupdate
RUN echo "if [ -s /etc/GeoIP.conf ]" >> /startscript.sh
RUN echo "then" >> /startscript.sh
RUN echo "   echo 'Please wait, geoipupdate is running'" >> /startscript.sh
RUN echo "   /usr/bin/geoipupdate" >> /startscript.sh
RUN echo "fi" >> /startscript.sh
# start ntopng
RUN echo "/usr/local/bin/ntopng /etc/ntopng/ntopng.conf" >> /startscript.sh
# Keep container running with the command below since we started
# just background services
RUN echo "tail -f /dev/null" >> /startscript.sh

RUN chmod +x /startscript.sh

ENTRYPOINT ["/startscript.sh"]
