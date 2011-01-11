#!/bin/sh

# settings
export APP="acabunoc"
export APPLIB="WormBase"
export WORKERS=5
export PORT=9003
export PERL5LIB=/usr/local/wormbase/website/acabunoc/extlib/lib/perl5:/usr/local/wormbase/website/acabunoc/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/website/acabunoc/lib:/usr/local/wormbase/website/acabunoc/extlib/gbrowse2/current/lib/perl5/x86_64-linux-gnu-thread-multi:$PERL5LIB

#export PATH="/usr/local/wormbase/website-classic/extlib/bin:$PATH"
export MODULEBUILDRC="/usr/local/wormbase/website/acabunoc/extlib/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/website/acabunoc/extlib"
export PATH="/usr/local/wormbase/website/acabunoc/extlib/bin:$PATH"


# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$0" )" && pwd )/wormbase-init.sh"
