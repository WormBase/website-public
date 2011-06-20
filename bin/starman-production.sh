#!/bin/sh

# settings
export APP="production"
export APPLIB="WormBase"
export WORKERS=10
export PORT=5000
export MAX_REQUESTS=500

# Set some configuration variables.
export WORMBASE_INSTALLATION_TYPE="production"

# Set my local configuration prefix so wormbase_production.conf takes precedence.
# Used to override the location of the user database.
export CATALYST_CONFIG_LOCAL_SUFFIX="production"


export PERL5LIB=/usr/local/wormbase/shared/extlib/lib/perl5:/usr/local/wormbase/shared/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:/usr/local/wormbase/shared/website/production/lib:$PERL5LIB
export MODULEBUILDRC="/usr/local/wormbase/shared/extlib/.modulebuildrc"
export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/shared/extlib"
export PATH="/usr/local/wormbase/shared/extlib/bin:$PATH"


# this runs site-init.sh, assuming it's in the same directory
. "$( cd "$( dirname "$0" )" && pwd )/wormbase-init.sh"
