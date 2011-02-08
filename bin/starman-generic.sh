#!/bin/sh

# settings
MYAPP=$1

if [ ! ${MYAPP} ]; then
   echo "USAGE: $0 [username]"
   exit
fi

export APP=$MYAPP
export APPLIB="WormBase"
export WORKERS=5

# Adjust the port as appropriate for your installation.
export PORT=5000
#export PERL5LIB=/usr/local/wormbase/website/$MYAPP/extlib/lib/perl5:/usr/local/wormbase/website/$MYAPP/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/$MYAPP/lib:$PERL5LIB
export PERL5LIB=/usr/local/wormbase/website/extlib/lib/perl5:/usr/local/wormbase/website/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/$MYAPP/lib:$PERL5LIB

#export PATH="/usr/local/wormbase/website-classic/extlib/bin:$PATH"
export MODULEBUILDRC="/usr/local/wormbase/website/extlib/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/website/extlib"
export PATH="/usr/local/wormbase/website/extlib/bin:$PATH"


# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$1" )" && pwd )/wormbase-init.sh"
