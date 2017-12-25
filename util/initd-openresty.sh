#!/bin/sh
#
# openresty - this script starts and stops the nginx daemon of OpenResty
#
# chkconfig:   - 85 15
# description: OpenResty is a scalable web platform by extending
#              NGINX with Lua
# processname: openresty
# config:      /usr/local/openresty/nginx/conf/nginx.conf
# config:      /etc/sysconfig/openresty
# pidfile:     /var/run/openresty.pid

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

nginx="/usr/local/openresty/nginx/sbin/nginx"
prog=$(basename $nginx)
pidfile=/var/run/openresty.pid

NGINX_CONF_FILE="/usr/local/openresty/nginx/conf/nginx.conf"

[ -f /etc/sysconfig/openresty ] && . /etc/sysconfig/openresty

lockfile=/var/lock/subsys/openresty

start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
    echo -n $"Starting $prog: "
    mkdir /dev/shm/proxy_temp
    mkdir /dev/shm/client_body_temp
    daemon $nginx -c $NGINX_CONF_FILE
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    rm -rf /dev/shm/proxy_temp
    rm -rf /dev/shm/client_body_temp
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    configtest || return $?
    stop
    sleep 1
    start
}

reload() {
    configtest || return $?
    echo -n $"Reloading $prog: "
    killproc $nginx -HUP
    RETVAL=$?
    echo
}

force_reload() {
    restart
}

configtest() {
    $nginx -q -t -c $NGINX_CONF_FILE
}

rh_status() {
    status $nginx
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart|configtest)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
        exit 2
esac

