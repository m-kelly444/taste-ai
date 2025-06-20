#!/bin/bash
set -e

cd ../../../
docker-compose up -d redis

sleep 5

cd production/zero_assumption_realtime/engines
python3 realtime_processor.py &
PROCESSOR_PID=$!

echo $PROCESSOR_PID > ../realtime_processor.pid

echo "Real-time processor started with PID: $PROCESSOR_PID"

wait $PROCESSOR_PID
