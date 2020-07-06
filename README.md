# ntopng for UDM/UDM pro

## Distributed under MIT license

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Project Notes
**Author:** Carlos Talbot (@tusc69 on ubnt forums)

The Dockerfile in this repository will create an image based on Debian Stretch and install the ntopng packages.

The first step is to ssh into the UDM and type the following command to download the Dockerfile file:

```
curl -Lo /tmp/Dockerfile https://raw.githubusercontent.com/tusc/ntopng-udm/master/Dockerfile
```
This will download a local copy of the Dockerfile to build from. The next command will build the image. This takes about a minute so have some patience. There are several packages
that need to be added to the Debian base.

```
docker build -t ntopng-image -f /tmp/Dockerfile
```

Finally, the last command will create a container with ntopng running on https port 3001

```
docker run -d --net=host --name ntopng localhost/ntopng-image
````
Open a web browser page to your UDM's ip address with port 3001 at the end using https. For example: https://192.168.1.1:3001


If you have to reboot the UDM you'll have to restart the container. You can do so by typing the following:

```
docker start ntopng
```

If you're interested in compiling your own version I have a Dockerfile available here that compiles ntopng from source: https://github.com/tusc/ntopng-udm/blob/master/source/Dockerfile

**Uninstalling**

To remove the docker instance and image you'll need to type the following at the UDM ssh prompt:


```
docker stop ntopng
docker rm ntopng
docker rmi ntopng-image
```
