#FROM arm64v8/debian:buster-slim
FROM debian:bullseye-slim

ARG SSL_NoVerify=1
ARG ParallelMakeJobs=1

ARG nDPI_Repo=https://github.com/ntop/nDPI.git
ARG nDPI_Branch=dev
ARG nDPI_Commit=9f7ef723327647813a369ab55336845cc7c1b0ab

ARG ntopng_Repo=https://github.com/ntop/ntopng
ARG ntopng_Branch=dev
ARG ntopng_Commit=c10ae0c105a4fd6983d58dcef638f2612b7b1993

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
RUN cd /root && GIT_SSL_NO_VERIFY=$SSL_NoVerify git clone $nDPI_Repo --branch $nDPI_Branch
RUN cd /root/nDPI && git checkout $nDPI_Commit && ./autogen.sh && ./configure && make -j$ParallelMakeJobs


# build ntopng
RUN cd /root && GIT_SSL_NO_VERIFY=$SSL_NoVerify git clone $ntopng_Repo --branch $ntopng_Branch
RUN cd /root/ntopng && git checkout $ntopng_Commit && ./autogen.sh && ./configure && make -j$ParallelMakeJobs

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

