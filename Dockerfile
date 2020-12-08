FROM debian:buster-slim

COPY entrypoint.sh /entrypoint.sh
COPY packages/*201206*.deb /tmp/

RUN apt-get update && apt-get --no-install-recommends -y install libsqlite3-0 libexpat1 redis-server librrd8 logrotate libcurl4 libpcap0.8 libldap-2.4-2 libhiredis0.14 \
            libssl1.1 libmariadbd19 lsb-release tar ethtool libcap2 bridge-utils libnetfilter-conntrack3 libzstd1 libmaxminddb0 \
            libradcli4 libjson-c3 libsnmp30 udev libzmq5 libcurl3-gnutls net-tools curl procps && rm -rf /var/lib/apt/lists/* \
        && curl -Lo /tmp/geoipupdate_2.3.1-1_arm64.deb  http://ftp.us.debian.org/debian/pool/contrib/g/geoipupdate/geoipupdate_2.3.1-1_arm64.deb \
        && dpkg -i /tmp/*.deb && rm /tmp/*.deb \
        && echo "-i=br0\n-n=1\n-W=3001" >> /etc/ntopng/ntopng.conf && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
