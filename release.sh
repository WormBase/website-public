#!/bin/bash

# ensure $VERSION is set
if [ -z "$VERSION" ] ; then
    echo "Error: environment variable VERSION must be set"
    exit 1

fi

# ensure no uncommited change
if ! git diff --quiet HEAD -- ; then
    echo "Error: all changes needs to be committed to git"
    exit 1
fi

# check if a release by this tag already exists
git fetch --tags
if [ $(git tag -l "$VERSION") ]; then
    echo "Error: tag $VERSION already exists. Please use another one."
    exit 1
fi

set -x #echo on

# update Version in Dockerrun.aws.json
sed -i -r 's/website:[^"]+/website:'"$VERSION"'/g' Dockerrun.aws.json

# release commit
git diff
git add Dockerrun.aws.json
git commit -m "release $VERSION"
git tag "$VERSION"
git push origin "$VERSION"

# build container
make build

# tag container
docker tag wormbase/website:latest 357210185381.dkr.ecr.us-east-1.amazonaws.com/wormbase/website:$VERSION

# push containers to AWS ECR
$(aws ecr get-login --no-include-email --region us-east-1)
docker push 357210185381.dkr.ecr.us-east-1.amazonaws.com/wormbase/website:$VERSION

# # post-release clean up
# sed -i -r 's/website:[^"]+/website:'"latest"'/g' Dockerrun.aws.json
# git add Dockerrun.aws.json
# git commit -m "post-release cleanup"

set -x #echo off

echo "Successfully created release $VERSION"
