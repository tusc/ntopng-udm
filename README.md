# ntopng for UDM/UDM pro

## Distributed under MIT license

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Project Notes
**Author:** Carlos Talbot (@tusc69 on ubnt forums)

# Installing

This is a prebuilt image of ntopng to run directly on an UDM or UDM PRO. The Docker image has been configured to perserve data between upgrades. ntopng uses an in memory database known as redis so writes to disk are minimal. In addition, the timeseries database (RRD) does not require much disk space. https://www.ntop.org/ntopng/ntopng-disk-requirements-for-timeseries-and-flows/. You can optionally configure the timeseries database to point to an external Influx database.

In order to install this image you will need to log into the UDM via ssh and type the following command:

```
podman pull tusc/ntopng-udm:latest
```
This will download the latest image to the UDM.

Next, we'll need to create two directories and download config files that will be saved between upgrades. This is a one time operation.

```
mkdir -p /mnt/data/ntopng/redis
mkdir -p /mnt/data/ntopng/lib
touch /mnt/data/ntopng/GeoIP.conf
curl -Lo /mnt/data/ntopng/ntopng.conf https://github.com/tusc/ntopng-udm/blob/master/ntopng/ntopng.conf?raw=true
curl -Lo /mnt/data/ntopng/redis.conf https://github.com/tusc/ntopng-udm/blob/master/ntopng/redis.conf?raw=true
```

Next, we want to create a container with ntopng running on https port 3001 using this image with the above config files.

```
podman run -d --net=host --restart always \
   --name ntopng \
   -v /mnt/data/ntopng/GeoIP.conf:/etc/GeoIP.conf \
   -v /mnt/data/ntopng/ntopng.conf:/etc/ntopng/ntopng.conf \
   -v /mnt/data/ntopng/redis.conf:/etc/redis/redis.conf \
   -v /mnt/data/ntopng/lib:/var/lib/ntopng \
   docker.io/tusc/ntopng-udm:latest
````
NOTE: If you prefer to use the external drive on the UMD pro to store the persistent data you can use the following to start up ntopng. Make sure to replace all references above from /mnt/data to /mnt/data_ext:

```
podman run -d --net=host --restart always \
   --name ntopng \
   -v /mnt/data_ext/ntopng/GeoIP.conf:/etc/GeoIP.conf \
   -v /mnt/data_ext/ntopng/ntopng.conf:/etc/ntopng/ntopng.conf \
   -v /mnt/data_ext/ntopng/redis.conf:/etc/redis/redis.conf \
   -v /mnt/data_ext/ntopng/lib:/var/lib/ntopng \
   docker.io/tusc/ntopng-udm:latest
```

Open a web browser page to your UDM's ip address with port 3001 at the end using https. For example: https://192.168.1.1:3001


If you have to reboot the UDM you'll have to restart the container. You can do so by typing the following:

```
podman start ntopng
```
Fortunately you can also take advantage of boostchicken's great tool to automatically start a Docker container after a reboot:
https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script

If you're interested in compiling your own version I have a Dockerfile available here that compiles ntopng from source: https://github.com/tusc/ntopng-udm/blob/master/source/Dockerfile

# GeoIP integration

If you want to see country flags next to hosts you'll need to setup a free account with maxmind.com. Follow the instructions from the link below and save the downloaded GeoIP.conf file on the UDM in the path /mnt/data/ntopng/GeoIP.conf. You can use scp or winscp to transfer the file over.  https://github.com/ntop/ntopng/blob/dev/doc/README.geolocation.md#using-geolocation-in-ntopng. Step 0 (geoipudate) has been done for you as it's included in this image.<br/>

When prompted on the version of geoipupdate select the option for older than 3.1.1.

Once you are done you can start the container. Anytime the docker container is started it will run a geoipupdate to download the latest GeoIP data.

# Customize settings

The default instance will listen on the LAN interface (br0). You can edit the file /mnt/data/ntopng/ntopng.conf on the UDM to change the settings. The default is -i=br0 (LAN), n=1 ( Decode DNS responses and resolve all numeric IPs ) and -W3001 (enable HTTPS port)

**NOTE** If you comment out the -i interface and let ntopng startup listening to all interfaces you will have to wait up to 30 seconds for all interfaces to register. This will also consume additional CPU and memory resources so be careful with this option.

You can also customize the settings for the redis database if you want to eliminates database saves to storage. That file is located at /mnt/data/ntopng/redis.conf

# Disable Redis
If you want to disable Redis and use an external server just set the env var "DISABLE_REDIS"
```
docker run -e DISABLE_REDIS=true tusc/ntopng-udm
```
## Building
Build on your UDM or build on another device using buildx and targeting arm64
```
docker buildx build --platform linux/arm64 -t ntopng-udm:latest --load .
```
# Upgrades

Whenever there is a new version of ntopng you can easily perform an upgrade by doing the following commands:

```
podman pull tusc/ntopng-udm:latest
podman stop ntopng
podman rm ntopng
podman run -d --net=host --restart always \
   --name ntopng \
   -v /mnt/data/ntopng/GeoIP.conf:/etc/GeoIP.conf \
   -v /mnt/data/ntopng/ntopng.conf:/etc/ntopng/ntopng.conf \
   -v /mnt/data/ntopng/redis.conf:/etc/redis/redis.conf \
   -v /mnt/data/ntopng/lib:/var/lib/ntopng \
   docker.io/tusc/ntopng-udm:latest
```

# Uninstalling

To remove the docker instance and image you'll need to type the following at the UDM ssh prompt:


```
podman stop ntopng
podman rm ntopng
podman rmi docker.io/tusc/ntopng-udm  (or "docker rmi ntopng-image" if you installed the first release)
```

# Console Lockout

If for whatever reason you find yourself locked out of the ntopng login prompt you can follow the steps on this page for resetting the password:
https://www.ntop.org/guides/ntopng/faq.html#cannot-login-into-the-gui

You have to connect to the containter in order to run the redis commands as referenced in the FAQ. Do so by typing the following below. You can type "exit" to get out of the container when you're done.
```
podman exec -it ntopng bash
```
