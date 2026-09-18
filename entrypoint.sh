#!/bin/bash
set -e

rm -f /rails/tmp/pids/server.pid

bundle check || bundle install

bundle exec rails db:prepare

exec "$@"
