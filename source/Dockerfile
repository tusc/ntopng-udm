#FROM arm64v8/debian:buster-slim
FROM debian:bullseye-slim

#ADD qemu-aarch64-static /usr/bin

RUN apt-get update && apt install -y apt-utils && apt-get --no-install-recommends -y install \
        autoconf \
        autogen \
        automake \
        bison \
        build-essential \
        clang \
        debhelper \
        default-libmysqlclient-dev \
        dkms \
        dpkg-sig \
        fakeroot \
        flex \
        git \
        gzip \
        libcairo2-dev \
        libcurl4-openssl-dev \
        libexpat1-dev \
        libhiredis-dev \
        libldap2-dev \
        libjson-c-dev \
        libmaxminddb-dev \
        libnetfilter-conntrack-dev \
        libnetfilter-queue-dev \
        librrd-dev \
        libpango1.0-dev \
        libpcap-dev \
        libpng-dev \
        libreadline-dev \
        libsnmp-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libtool-bin \
        libxml2-dev \
        libzmq5-dev \
        linux-headers-arm64 \
        npm \
        pkg-config \
        redis-server \
        rename \
        rrdtool \
        sudo \
        wget \
        zlib1g-dev \
        && rm -rf /var/lib/apt/lists/* \
        && npm install -g uglify-es clean-css-cli


# build nDPI which is required by ntopng
RUN cd /root && GIT_SSL_NO_VERIFY=1 git clone https://github.com/ntop/nDPI.git --branch 5.2-stable
RUN cd /root/nDPI && ./autogen.sh && ./configure && make -j8


# build ntopng
RUN cd /root && GIT_SSL_NO_VERIFY=1 git clone https://github.com/ntop/ntopng --branch 5.2-stable
RUN cd /root/ntopng && ./autogen.sh && ./configure && make -j8

RUN mkdir -p /root/dat_files && cd /root/dat_files && \
    wget https://download.db-ip.com/free/dbip-country-lite-$(date +"%Y-%m").mmdb.gz && \
    wget https://download.db-ip.com/free/dbip-city-lite-$(date +"%Y-%m").mmdb.gz && \
    wget https://download.db-ip.com/free/dbip-asn-lite-$(date +"%Y-%m").mmdb.gz && \
    gunzip ./*

# build deb packages
# This requires you have a .gnupg directory present as the Makefile will try to sign all the deb packages
# you can optionally comment those lines out
#
# This last is currently commented since the automatic package builder does not detect the debian 10 buster container and inserts the wrong dependacies in 
# ntopng/packages/debian/debian.ntopng
RUN cd /root/ntopng/packages/debian && \
            ./configure && \
            sed -i '/dpkg-sig/s//#&/' Makefile && \
            make && \
            mkdir -p debs && \
            mv *.deb debs

