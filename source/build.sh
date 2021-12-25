#!/bin/sh

if [ -z $DOCKER_IMAGE ]; then
    printf "Specify the Docker Image with the DOCKER_IMAGE environment variable"
    return 1
fi

docker buildx build --platform linux/arm64 -t "$DOCKER_IMAGE" --load .

