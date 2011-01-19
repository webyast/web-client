#!/bin/sh
rm -f log/development.log
rake db:migrate
rake sass:update
if [ -f public/javascripts/min/base-min.js ] ; then
  echo "base-min.js already available"
else
  rake js:base
fi
ruby script/server --port=54984
