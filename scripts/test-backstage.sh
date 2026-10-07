#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
PYTHON_BIN=${PYTHON_BIN:-python3}
mkdir -p "$ROOT_DIR/.generated"
cd "$ROOT_DIR/backstage"
node .yarn/releases/yarn-4.13.0.cjs workspace backend start --config ../../app-config.yaml --config ../../app-config.local.yaml > "$ROOT_DIR/.generated/backstage-test.log" 2>&1 &
TASK_BACKEND_PID=$!
trap 'kill "$TASK_BACKEND_PID" 2>/dev/null || true' EXIT
for attempt in $(seq 1 90); do
  if curl -fsS http://localhost:7007/.backstage/health/v1/readiness >/dev/null 2>&1; then break; fi
  kill -0 "$TASK_BACKEND_PID" 2>/dev/null || { cat "$ROOT_DIR/.generated/backstage-test.log"; exit 1; }
  sleep 2
done
"$PYTHON_BIN" "$ROOT_DIR/scripts/test-backstage-dry-run.py"
