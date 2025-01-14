#!/usr/bin/env bash

docker rm -f mycontainer
docker build -t orlop-base:dev .
#docker run -it orlop-base /bin/bash -c
