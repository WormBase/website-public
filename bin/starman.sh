#!/bin/sh

# settings
export APP="staging"
export APPLIB="WormBase"
export WORKERS=5
export PORT=5000
export PERL5LIB=/usr/local/wormbase/website/staging/extlib/lib/perl5:/usr/local/wormbase/website/staging/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/staging/lib:/usr/local/wormbase/website/staging/extlib/gbrowse2/current/lib/perl5/x86_64-linux-gnu-thread-multi:$PERL5LIB

export MODULEBUILDRC="/usr/local/wormbase/website/staging/extlib/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/website/staging/extlib"
export PATH="/usr/local/wormbase/website/staging/extlib/bin:$PATH"


# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$0" )" && pwd )/wormbase-init.sh"
