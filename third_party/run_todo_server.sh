#!/usr/bin/env bash
set -euo pipefail

# Always run from the script's directory (repo root)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

PORT="${PORT:-3000}"
BASE_URL="${BASE_URL:-http://localhost}:${PORT}"
HEALTH_URL="${BASE_URL}"

echo "Checking if Todo server is already responding on ${HEALTH_URL} ..."
if curl -sS "${HEALTH_URL}" >/dev/null 2>&1; then
    echo "TodoBackend server already running at ${HEALTH_URL}"
    exit 0
fi

echo "No server detected, starting one..."
cd go-todo-app && PORT="${PORT}" BASE_URL="${BASE_URL}" go run ./cmd > ../go_todo_app_server.log 2>&1 &
SERVER_PID=$!
cd "$ROOT_DIR"
echo "Started server (pid ${SERVER_PID}), waiting for it to become healthy..."

# Wait up to ~10 seconds for the server to come up
for i in {1..20}; do
    if curl -sS "${HEALTH_URL}" >/dev/null 2>&1; then
        echo "Server is UP at ${HEALTH_URL}"
        exit 0
    fi
    sleep 0.5
done

echo "Server did not respond on ${HEALTH_URL} after 10 seconds."
echo "Check server.log for details. (PID: ${SERVER_PID})"
exit 1
