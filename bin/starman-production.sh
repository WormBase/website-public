#!/bin/sh

# settings
export APP="production"
export APPLIB="WormBase"
export WORKERS=5
export PORT=5000

# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$0" )" && pwd )/wormbase-init.sh"
