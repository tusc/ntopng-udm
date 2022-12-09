FROM debian:bullseye-slim

RUN mkdir -p /root/packages

COPY entrypoint.sh /entrypoint.sh
COPY packages/*_5.1*.deb /root/packages

RUN sed -i -e's/ main/ main contrib/g' /etc/apt/sources.list && \
    apt-get update && apt-get --no-install-recommends -y install \
            libsqlite3-0 \
            libexpat1 \
            redis-server \
            librrd8 \
            logrotate \
            libcurl4 \
            libpcap0.8 \
            libldap-2.4-2 \
            libhiredis0.14 \
            libssl1.0 \
            libmariadb3 \
            whiptail \
            libnuma1 \
            libnetfilter-queue1 \
            lsb-release \
            tar \
            ethtool \
            libcap2 \
            bridge-utils \
            libnetfilter-conntrack3 \
            libzstd1 \
            libmaxminddb0 \
            libradcli4 \
            libjson-c5 \
            libsnmp40 \
            udev \
            libzmq5 \
            libcurl3-gnutls \
            net-tools \
            curl \
            procps && rm -rf /var/lib/apt/lists/*

RUN curl -Lo /tmp/geoipupdate_2.3.1-1_arm64.deb http://ftp.us.debian.org/debian/pool/contrib/g/geoipupdate/geoipupdate_2.3.1-1_arm64.deb

RUN dpkg -i /root/packages/*.deb && mkdir -p /etc/ntopng && echo "-i=br0\n-n=1\n-W=3001" >> /etc/ntopng/ntopng.conf && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

