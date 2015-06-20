#!/bin/sh
set -e


docker build \
    -t piotrminkina/squid-proxy:3.5 \
    "$@" \
    src/

docker tag \
    -f \
    piotrminkina/squid-proxy:3.5 \
    piotrminkina/squid-proxy:latest
