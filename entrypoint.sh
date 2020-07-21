#!/bin/bash

set -e
if [ -z "$DISABLE_REDIS" ]; then
  /etc/init.d/redis-server start
fi

if [ -s /etc/GeoIP.conf ]
then
   echo 'Please wait, geoipupdate is running'
   /usr/bin/geoipupdate
fi

ntopng /etc/ntopng/ntopng.conf