#!/bin/bash
# Start RQ worker script

set -e

echo "Starting RQ worker..."
echo "Redis URL: ${REDIS_URL:-redis://localhost:6379/0}"

poetry run rq worker \
    --url "${REDIS_URL:-redis://localhost:6379/0}" \
    --name "makiti-worker" \
    --burst \
    default


