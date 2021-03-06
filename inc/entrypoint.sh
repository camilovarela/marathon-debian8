#!/bin/sh
set -e

# Config Marathon
usage() {
cat <<-EOUSAGE
    usage: command [args]

    command:
        marathon: Initialize marathon service
EOUSAGE
}

usage_marathon() {
cat <<-EOUSAGE
    usage: marathon <zk_host_ip>

    options:
        zk_host_ip: zookeeper host IP container
EOUSAGE
}

subcommand="$1"
case "$subcommand" in
    marathon)
    {
        shift

        ZK_HOST_IP=$1

        if [ "$ZK_HOST_IP" = "" ]; then
            usage_marathon
            exit 1
        fi

        # zookeeper config: read from zookeeper server to feed /etc/mesos/zk
        ZKCFG=`echo conf | nc $ZK_HOST_IP 2181 | awk -F: '/^server.[0-9]/ {print $1}' | awk -F= '{printf "%s:2181\n", $2}'`

        # updating files /etc/marathon/conf/ with current zk config
        > /etc/marathon/conf/hostname
        > /etc/marathon/conf/http_port
        > /etc/marathon/conf/master
        > /etc/marathon/conf/zk

        IPADDRESS=`ifconfig eth0 | awk '/inet/{print $2}' | awk -F: '{print $2}'`
        echo "$IPADDRESS" >> /etc/marathon/conf/hostname

        echo "`echo "$ZKCFG" | paste -sd"," | sed 's/.*/zk:\/\/&\/mesos/'`" >> /etc/marathon/conf/master
        echo "`echo "$ZKCFG" | paste -sd"," | sed 's/.*/zk:\/\/&\/marathon/'`" >> /etc/marathon/conf/zk
        echo "8080" >> /etc/marathon/conf/http_port

        #disable zookeeper that comes with mesos as dependency
        echo manual > /etc/init/zookeeper.override
        service zookeeper stop

        # marathon initializing
        echo "Running Marathon service on $IPADDRESS..."
        cmd="/opt/marathon/bin/start \
            --master `cat /etc/marathon/conf/master` \
            --zk `cat /etc/marathon/conf/zk` \
            --http_port `cat /etc/marathon/conf/http_port` \
            --hostname `cat /etc/marathon/conf/hostname`"
        $cmd
        echo "Marathon service started"
    }
    ;;
    *)
    {
        echo "error: unknown command: ${subcommand}"
        usage
    } >&2
    exit 1
    ;;
esac

exit 0
