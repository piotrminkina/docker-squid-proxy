#!/bin/sh
set -e


CACHE_DIR=${CACHE_DIR:-/var/cache/squid/}
LOG_DIR=${LOG_DIR:-/var/log/squid/}

docker run \
    --name squid-proxy \
    --rm \
    --read-only \
    -v "${CACHE_DIR}":/var/cache/squid/ \
    -v "${LOG_DIR}":/var/log/squid/ \
    piotrminkina/squid-proxy \
    squid-check

docker run \
    --name squid-proxy \
    --rm \
    --read-only \
    --net=host \
    --cap-drop ALL \
    --cap-add SETUID \
    --cap-add SETGID \
    --cap-add NET_ADMIN \
    --cap-add NET_RAW \
    --cap-add KILL \
    -v "${CACHE_DIR}":/var/cache/squid/ \
    -v "${LOG_DIR}":/var/log/squid/ \
    "$@" \
    piotrminkina/squid-proxy
