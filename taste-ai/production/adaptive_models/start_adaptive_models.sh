#!/bin/bash
set -e

cd ../../../
docker-compose up -d redis

sleep 5

cd production/adaptive_models/engines
python3 adaptive_model_engine.py &
ENGINE_PID=$!

echo $ENGINE_PID > ../adaptive_models.pid

echo "Adaptive model engine started with PID: $ENGINE_PID"

wait $ENGINE_PID
