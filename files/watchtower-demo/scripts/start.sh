#!/bin/bash
set -e

echo "==> registry"
docker compose up -d registry
sleep 3

echo "==> build v1.0.0"
bash scripts/release.sh v1.0.0 "#06b6d4"

echo "==> app + watchtower"
docker compose up -d app watchtower

sleep 2

echo ""
echo "Done."
echo "App  : http://localhost:8090"
echo "Logs : bash scripts/logs.sh"
echo "Next : bash scripts/release.sh v2.0.0"