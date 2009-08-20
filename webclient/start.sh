#!/bin/sh
rm -f log/development.log
rake db:migrate
ruby script/server --debugger
