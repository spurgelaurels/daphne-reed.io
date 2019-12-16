#!/bin/bash
#
#  TAG EXTRACTOR
#  awk '/tags:/,/\---/ { if ($0 !~ /(\---|tags\:)/) { print } }' < * | sort -u

JEKYLLROOT="/home/daphne/src/daphne-reed.io"
PAGESROOT="/home/daphne/src/spurgelaurels.github.io"

cd $JEKYLLROOT
bundle exec jekyll build &&
cd _site && cp -rp * $PAGESROOT
cd $PAGESROOT && git add . && git commit -m "Automatic deploy" && git push

