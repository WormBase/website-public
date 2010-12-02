#!/bin/sh

# settings
export APP="development"
export APPLIB="WormBase"
export WORKERS=5
export PORT=5000
export PERL5LIB=/usr/local/wormbase/website/development/extlib/lib/perl5:/usr/local/wormbase/website/development/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/development/lib:$PERL5LIB

#export PATH="/usr/local/wormbase/website-classic/extlib/bin:$PATH"
export MODULEBUILDRC="/usr/local/wormbase/website/development/extlib/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/website/development/extlib"
export PATH="/usr/local/wormbase/website/development/extlib/bin:$PATH"


# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$0" )" && pwd )/wormbase-init.sh"
