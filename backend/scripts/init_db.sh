#!/bin/bash
# Initialize database script

set -e

echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h localhost -p ${POSTGRES_PORT:-5432} -U ${POSTGRES_USER:-makiti}; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

echo "PostgreSQL is up - executing migrations"
poetry run alembic upgrade head

echo "Database initialized successfully!"


