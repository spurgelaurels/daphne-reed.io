#!/bin/bash
#
#  TAG EXTRACTOR
#  awk '/tags:/,/\---/ { if ($0 !~ /(\---|tags\:)/) { print } }' < * | sort -u
bundle exec jekyll build &&

scp -r _site/* daphne-reed.io:/var/www/html
#s3_website push
