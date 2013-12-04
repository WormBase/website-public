#!/bin/bash

# Gets "assemblies.VERSION.json" for a particular WormBase release VERSION.
#
# The JSON file contains information about the various species and BioProjects.

cwd="`pwd`"
version="$1"

if [ $# -ne 1 ] ; then
  echo "WormBase release version needs to be provided."
  echo ""
  echo "Example: ./script/get_assemblies_metadata.sh WS240"
  exit 1
fi

if [ -d website ] ; then
  cd website/metadata
elif [ -d metadata ] ; then
  cd metadata
else
  echo "This script must be executed in 'website' or one level above."
  exit 2
fi

wget ftp://ftp.wormbase.org/pub/wormbase/releases/$version/species/ASSEMBLIES.$version.json

cd "$cwd"

