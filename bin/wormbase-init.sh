#!/bin/bash

. /lib/lsb/init-functions

if [ ! $APP ]; then
    echo "\$APP is not defined, please do not call this script directly."
    echo <<EOF 

To run this script, set some environment variables like:
export APP="production"    # Should contain a full checked out version of source. Becomes /usr/local/wormbase/website/$APP
export APPLIB="WormBase"   # WormBase::Web?
export WORKERS=5
export PORT=5000
export MAX_REQUESTS=1000
# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$0" )" && pwd )/wormbase-init.sh"
EOF

    exit 1
fi

export APPDIR="/usr/local/wormbase/website/$APP"
export PIDDIR=/tmp
export PIDFILE=$PIDDIR/${APP}.pid
export STARMAN="$APPDIR/bin/starman-wormbase.sh"

if [ ! -d $APPDIR ]; then
    echo "$APPDIR does not exist"
    exit 1
fi

check_running() {
    [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) >/dev/null 2>&1
}

check_compile() {
  if ( cd $APPDIR ; perl -Ilib -M$APPLIB -ce1 ) ; then
    return 1
  else
    return 0
  fi
}

_start() {

  /sbin/start-stop-daemon --start --pidfile $PIDFILE \
  --chdir $APPDIR --startas $STARMAN

  echo ""
  echo "Waiting for $APP to start..."

  for i in 1 2 3 4 ; do
    sleep 1
    if check_running ; then
      echo "$APP is now starting up"
      return 0
    fi
  done

  # sometimes it takes two tries.
  echo "Failed. Trying again..."
  /sbin/start-stop-daemon --start --pidfile $PIDFILE \
  --chdir $APPDIR --startas $STARMAN

  for i in 1 2 3 4 ; do
    sleep 1
    if check_running ; then
      echo "$APP is now starting up"
      return 0
    fi
  done

  return 1
}

start() {
    log_daemon_msg "Starting $APP" $STARMAN
    echo ""

    if check_running; then
        log_progress_msg "already running"
        log_end_msg 0
        exit 0
    fi

    rm -f $PIDFILE 2>/dev/null

    _start
    log_end_msg $?
    return $?
}

stop() {
    log_daemon_msg "Stopping $APP" $STARMAN
    echo ""

    /sbin/start-stop-daemon --stop --oknodo --pidfile $PIDFILE
    sleep 3
    log_end_msg $?
    return $?
}

restart() {
    log_daemon_msg "Restarting $APP" $STARMAN
    echo ""

    if check_compile ; then
        log_failure_msg "Error detected; not restarting."
        log_end_msg 1
        exit 1
    fi

    /sbin/start-stop-daemon --stop --oknodo --pidfile $PIDFILE
    _start
    log_end_msg $?
    return $?
}


# See how we were called.
case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart|force-reload)
        restart
    ;;
    *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac
exit $?
