#!/bin/bash
#
#  TAG EXTRACTOR
#  awk '/tags:/,/\---/ { if ($0 !~ /(\---|tags\:)/) { print } }' < * | sort -u

WWWROOT="/www/daphne-reed.io"

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 1
fi

bundle exec jekyll build &&
for HOST in "$@"
  do 
    scp -r _site/* $HOST:$WWWROOT
  done


