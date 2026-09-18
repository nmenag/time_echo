#!/bin/bash
set -e

rm -f /rails/tmp/pids/server.pid

bundle check || bundle install

until pg_isready -h db -U postgres; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

bundle exec rails db:prepare

exec "$@"
