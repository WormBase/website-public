#!/bin/bash

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

PSGIAPP="$APPDIR/script/wormbase_psgi.psgi"
echo "Starting $PSGIAPP, pidfile $PIDFILE..."
starman -I$APPDIR/lib $PSGIAPP --workers $WORKERS --pid $PIDFILE --port $PORT --max-requests $MAX_REQUESTS --daemonize
