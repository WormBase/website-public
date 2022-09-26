#!/bin/bash
set -e

export APP="staging"

#export PERL5LIB="/usr/local/wormbase/extlib/lib/perl5:/usr/local/wormbase/extlib/lib/perl5/x86_64-linux-gnu-thread-multi:$ENV{APP_HOME}/lib:$PERL5LIB"
#export MODULEBUILDRC="/usr/local/wormbase/extlib/.modulebuildrc"
#export PERL_MM_OPT="INSTALL_BASE=/usr/local/wormbase/extlib"
#export PATH="/usr/local/wormbase/extlib/bin:$PATH"

source /etc/profile
export PATH="${HOME}/.local/bin:$PATH";

#perl Makefile.PL

# Output of unit tests; path cannot contain spaces:
export TEST_LOG=/tmp/jenkins_test_log_`date '+%s'`.log

# build container
make build

# Unit tests: WormBase API and REST API
#make build-run-test | tee $TEST_LOG

# Check if there was an error reported by the unit tests, return non-zero if that is the case
if [ "`grep -E '^[ ]*not ok [0-9]+ ' $TEST_LOG`" != '' ] ; then
    rm -f $TEST_LOG
    exit 1
fi

rm -f $TEST_LOG

# tag container
docker tag wormbase/website:latest 357210185381.dkr.ecr.us-east-1.amazonaws.com/wormbase/website:latest

# push containers to AWS ECR
$(aws ecr get-login --no-include-email --region us-east-1)
docker push 357210185381.dkr.ecr.us-east-1.amazonaws.com/wormbase/website:latest

# deploy container

# make dockerrun-latest
# This just serves to replace the version in docker-compose.yml (formerly: Dockerrun.aws.json" with "latest"
# Sed is greedy, however, and breaks other config  Disabled in the jenkins environment for now
#make dockerrun-latest

#cat Dockerrun.aws.json
#git add Dockerrun.aws.json
# Let's cat output so we can see file contents in the jenkins log
cat docker-compose.yml
git add docker-compose.yml
git commit -m "use latest wormbase/website container"  # only needed locally and subsequent build will discard this commit


if [ "$1" == "local" ]; then
    make staging-deploy-no-eb
else
    echo "\$1 is NOT local"
    make staging-deploy
fi
