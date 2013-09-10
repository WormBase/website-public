#!/bin/bash

usage() {
  echo "Usage: $0 gzipped_gff3_file"
  echo "Prints the source/type pairs as they appear in a GFF3 file."
  echo "Output is suitable for use in GBrowse configuration files."
}

if [[ $# -lt 1 ]] ; then
  echo "A parameter has to be provided."
  usage
  exit 1
fi

if [[ $# -gt 1 ]] ; then
  echo "Only one parameter should be provided."
  usage
  exit 2
fi

GZIPPED_GFF3_FILE=$1

gzip -cd $GZIPPED_GFF3_FILE | grep -v -E '^#' | cut -f 2,3 | uniq | awk -F '	' '{ print $2":"$1 }' | sort | uniq

