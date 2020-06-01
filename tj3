#!/bin/bash
#
# Runs TaskJuggler using the remote docker image 
#
# Copyright (c) 2020, Roozbeh Farahbod
#

DOCKER_IMAGE=theroozbeh/tj3:latest

docker run \
    --rm -it \
    --net="none" \
    -v `pwd`:/tj3 \
    -u `id -u` \
    ${DOCKER_IMAGE} "$@"
