#!/bin/sh

# settings
MYAPP=$1
export APP=$MYAPP
export APPLIB="WormBase"
export WORKERS=5
export PORT=5000
export PERL5LIB=/usr/local/wormbase/website/$MYAPP/extlib/lib/perl5:/usr/local/wormbase/website/$MYAPP/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/$MYAPP/lib:$PERL5LIB

#export PATH="/usr/local/wormbase/website-classic/extlib/bin:$PATH"
export MODULEBUILDRC="/usr/local/wormbase/website/$MYAPP/extlib/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/website/$MYAPP/extlib"
export PATH="/usr/local/wormbase/website/$MYAPP/extlib/bin:$PATH"


# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$1" )" && pwd )/wormbase-init.sh"
