#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Install gems if they aren't installed or need updating
bundle check || bundle install

# Wait for database to be ready
until pg_isready -h db -U postgres; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

# Prepares database (creates and runs migrations)
bundle exec rails db:prepare

# Execute the main container process
exec "$@"
