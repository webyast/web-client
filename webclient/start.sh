#!/bin/sh
rm -f log/development.log
rake db:migrate
rake sass:update
if [ -f public/javascripts/min/base-min.js ] ; then
  echo "base-min.js already available"
else
  rake js:base
fi

if [ -f ../plugins/users/public/javascripts/min/users-min.js ] ; then
  echo "users-min.js already available"
else
  cd ../plugins/users/
  rake js:users
  cd -
fi

if [ -f ../plugins/status/public/javascripts/min/status-min.js ] ; then
  echo "status-min.js already available"
else
  cd ../plugins/status/
  rake js:status
  cd -
fi
ruby script/server --port=54984
