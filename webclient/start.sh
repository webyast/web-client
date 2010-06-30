#!/bin/sh
rm -f log/development.log
rake db:migrate
rake sass:update
ruby script/server --port=54984
