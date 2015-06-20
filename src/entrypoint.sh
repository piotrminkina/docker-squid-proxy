#!/bin/sh
set -e


FORWARD_PORTS="80"
SIGNALS="HUP INT QUIT KILL TERM"

squid_check() {
    [ -d /var/cache/squid/ ] || mkdir -p /var/cache/squid/
    [ 'squid:squid' = `stat -c %U:%G /var/cache/squid/` ] || chown squid:squid /var/cache/squid/

    [ -d /var/log/squid/ ] || mkdir -p /var/log/squid/
    [ 'squid:squid' = `stat -c %U:%G /var/log/squid/` ] || chown squid:squid /var/log/squid/

    gosu squid squid -z
}

squid_start() {
    gosu squid squid -N "$@" & PID=$!
}

install_forwards() {
    set +e
    for PORT in ${FORWARD_PORTS}; do
        iptables -t nat -A PREROUTING -p tcp --dport ${PORT} -j REDIRECT --to 3129 -w
    done
    set -e
}

uninstall_forwards() {
    set +e
    for PORT in ${FORWARD_PORTS}; do
        iptables -t nat -D PREROUTING -p tcp --dport ${PORT} -j REDIRECT --to 3129 -w
    done
    set -e
}

install_signals() {
    for SIGNAL in ${SIGNALS}; do
        trap "kill -s ${SIGNAL} ${PID}" ${SIGNAL}
    done
}


if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
    squid_check
    squid_start "$@"

    install_forwards
    trap "uninstall_forwards" EXIT
    install_signals

    wait ${PID}
    EXIT_CODE=$?

    exit ${EXIT_CODE}
fi

if [ "$1" = 'squid-check' ]; then
    squid_check
else
    exec "$@"
fi
