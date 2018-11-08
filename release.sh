# ensure $VERSION is set
echo $VERSION;
if [ -z "$VERSION" ] ; then
    echo "Environment variable VERSION must be set"
    exit 1

fi

if ! git diff --quiet HEAD -- ; then
    echo "All changes needs to be committed to git"
    exit 1
fi

# ensure no uncommited change

# build container
make build

# tag container
docker tag wormbase/website:latest 357210185381.dkr.ecr.us-east-1.amazonaws.com/wormbase/website:$VERSION

# push containers to AWS ECR
$(aws ecr get-login --no-include-email --region us-east-1)
docker push 357210185381.dkr.ecr.us-east-1.amazonaws.com/wormbase/website:$VERSION
