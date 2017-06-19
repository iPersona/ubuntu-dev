#!/bin/bash

host_shared_dir=/d/shared
if [ "$(uname)" == "Darwin" ]; then
    host_shared_dir=~/Documents/dev/docker
fi
docker run -t -i -v $host_shared_dir:/mnt/shared omi/ubuntu-dev:latest /bin/zsh

