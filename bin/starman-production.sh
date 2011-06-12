#!/bin/sh

# settings
export APP="production"
export APPLIB="WormBase"
export WORKERS=5
export PORT=5000

#export PERL5LIB=/usr/local/wormbase/extlib/lib/perl5:/usr/local/wormbase/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/production/lib:$PERL5LIB
#export MODULEBUILDRC="/usr/local/wormbase/extlib/.modulebuildrc"
#export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/extlib"
#export PATH="/usr/local/wormbase/extlib/bin:$PATH"


export PERL5LIB=/usr/local/wormbase/shared/extlib/lib/perl5:/usr/local/wormbase/shared/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/shared/website/production/lib:$PERL5LIB
export MODULEBUILDRC="/usr/local/wormbase/shared/extlib/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/shared/extlib"
export PATH="/usr/local/wormbase/shared/extlib/bin:$PATH"


# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$0" )" && pwd )/wormbase-init.sh"
