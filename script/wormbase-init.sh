#!/bin/bash

. /lib/lsb/init-functions

# If the APP environment variable isn't set, 
# assume we are running in production.
if [ ! $APP ]; then
    echo "   ---> APP is not defined; assuming a production deployment"
    export APP=production
    export APPROOT=/usr/local/wormbase/website
    export DAEMONIZE=true
    export PORT=5000
    export WORKERS=10

    export PERL5LIB=/usr/local/wormbase/extlib/lib/perl5:/usr/local/wormbase/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/production/lib:$PERL5LIB
    export MODULEBUILDRC="/usr/local/wormbase/extlib/.modulebuildrc"
    export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/extlib"
    export PATH="/usr/local/wormbase/extlib/bin:$PATH"
    
# Set some configuration variables.
    export WORMBASE_INSTALLATION_TYPE="production"
    
# Set my local configuration prefix so wormbase_production.conf takes precedence.
# Used to override the location of the user database.
    export CATALYST_CONFIG_LOCAL_SUFFIX="production"
    
fi

# Fetch local defaults
PIDDIR=/tmp
PIDFILE=$PIDDIR/${APP}.pid
APPLIB=$APPROOT/$APP/WormBase


if [ ! -d "$APPROOT/$APP" ]; then
    echo "\$APPROOT/$APP does not exist"
    exit 1
fi

if [ ! $WORKERS ]; then
    echo "\$WORKERS is not defined"
    exit 1
fi

if [ ! $PORT ]; then
    echo "\$PORT is not defined"
    exit 1
fi

if [ ! $MAX_REQUESTS ]; then
    MAX_REQUESTS=1000
fi



# Which starman are we running?
STARMAN=`which starman`
STARMAN_OPTS="-I$APPDIR/lib --workers $WORKERS --pid $PIDFILE --port $PORT --max-request $MAX_REQUESTS --daemonize $APPDIR/wormbase.psgi"


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

    echo "Launching WormBase app with the following parameters..."
    echo "     appdir  : $APPROOT/$APP"
    echo "     pidfile : $PIDFILE"
    echo "     workers : $WORKERS"
    echo "    max_reqs : $MAX_REQUESTS"
    echo "        port : $PORT" 
    
#  /sbin/start-stop-daemon --start --pidfile $PIDFILE \
#  --chdir $APPROOT/$APP --startas $STARMAN "$STARMAN_OPTS"
    
#  /sbin/start-stop-daemon --start --pidfile $PIDFILE \
#  --chdir $APPROOT/$APP --exec $STARMAN -- "$STARMAN_OPTS"
    
    if [ $DAEMONIZE ]; then
	/sbin/start-stop-daemon --start --pidfile $PIDFILE \
	    --chdir $APPROOT/$APP --exec $STARMAN -- -I$APPROOT/$APP/lib --workers $WORKERS --pid $PIDFILE --port $PORT --max-request $MAX_REQUESTS --daemonize $APPROOT/$APP/wormbase.psgi
    else
	/sbin/start-stop-daemon --start --pidfile $PIDFILE \
	    --chdir $APPROOT/$APP --exec $STARMAN -- -I$APPROOT/$APP/lib --workers $WORKERS --pid $PIDFILE --port $PORT --max-request $MAX_REQUESTS  $APPROOT/$APP/wormbase.psgi
    fi
    
    echo ""
    echo "   Attempting to start..."
    
    for i in 1 2 3 4 ; do
	sleep 1
	if check_running ; then
	    echo "     $APP is now starting up"
	    return 0
	fi
    done

  # Try again if we've failed.
    echo "   Failed. Trying again..."
    if [ $DAEMONIZE ]; then
	/sbin/start-stop-daemon --start --pidfile $PIDFILE \
	    --chdir $APPROOT/$APP --exec $STARMAN -- -I$APPROOT/$APP/lib --workers $WORKERS --pid $PIDFILE --port $PORT --max-request $MAX_REQUESTS --daemonize $APPROOT/$APP/wormbase.psgi
    else
	/sbin/start-stop-daemon --start --pidfile $PIDFILE \
	    --chdir $APPROOT/$APP --exec $STARMAN -- -I$APPROOT/$APP/lib --workers $WORKERS --pid $PIDFILE --port $PORT --max-request $MAX_REQUESTS  $APPROOT/$APP/wormbase.psgi
    fi
    
    for i in 1 2 3 4 ; do
	sleep 1
	if check_running ; then
	    echo "     $APP is now starting up"
	    return 0
	fi
    done
    
    return 1
}

start() {
    #log_daemon_msg "Starting $APP" $STARMAN
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
