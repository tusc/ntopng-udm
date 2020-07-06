FROM debian:stretch-slim
RUN apt-get update && apt-get install build-essential \
        libtool \
        autoconf \
        automake \
        pkg-config \
        wget \
        git \
        sudo \
        redis-server \
        libjson-c-dev \
        libssl-dev \
        libcurl4-gnutls-dev \
        libmaxminddb-dev \
        libsqlite3-dev \
        libreadline-dev \
        libxml2-dev \
        librrd-dev \
        linux-headers-arm64 \
        libpcap-dev \
        libzmq3-dev
        debhelper \
        fakeroot \
        dpkg-sig

# build nDPI which is required by ntopng
RUN cd /root \
        && git clone https://github.com/ntop/nDPI.git; cd nDPI; ./autogen.sh; make -j4


# build ntopng
RUN cd /root \
        && git clone https://github.com/ntop/ntopng \
        && cd ntopng \
        && ./autogen.sh \
        && ./configure \
        && make -j4 \
        && make install

# build deb packages
# This requires you have a .gnupg directory present as the Makefile will try to sign all the deb packages
# you can optionally comment those lines out
RUN cd packages/ubuntu && ./configure && make
