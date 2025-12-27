#!/bin/bash
set -e

# Remove stale server.pid if it exists
if [ -f /tmp/server.pid ]; then
  rm /tmp/server.pid
fi

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

# Wait for database to be ready
wait_for_db() {
  echo "Waiting for database..."
  while ! pg_isready -h "$DATABASE_HOST" -p "${DATABASE_PORT:-5432}" -U "$DATABASE_USERNAME" -q; do
    echo "Database is unavailable - sleeping"
    sleep 2
  done
  echo "Database is ready!"
}

# Only wait for DB if we're running a Rails command that needs it
case "$1" in
  rails|rake|bundle)
    if [ -n "$DATABASE_HOST" ]; then
      wait_for_db
      
      # Run database migrations/setup
      echo "Running db:prepare..."
      bundle exec rails db:prepare
    fi
    ;;
esac

# Execute the main command
exec "$@"


