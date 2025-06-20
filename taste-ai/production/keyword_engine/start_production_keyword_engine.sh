#!/bin/bash
set -e

echo "🚀 Starting PRODUCTION Keyword Engine..."

# Ensure Redis is running
cd ../../../
docker-compose up -d redis

echo "⏳ Waiting for Redis..."
sleep 5

echo "🎯 Starting keyword discovery..."
cd production/keyword_engine/discovery
python3 live_keyword_engine.py &
DISCOVERY_PID=$!

echo "⚡ Starting keyword optimization..."
cd ../optimization
python3 live_optimizer.py &
OPTIMIZER_PID=$!

echo "✅ PRODUCTION Keyword Engine started"
echo "   Discovery PID: $DISCOVERY_PID"
echo "   Optimizer PID: $OPTIMIZER_PID"

# Store PIDs
echo "$DISCOVERY_PID,$OPTIMIZER_PID" > ../keyword_engine.pids

echo "🔍 Keyword engine is now discovering and optimizing keywords continuously..."
echo "📊 Monitor with: redis-cli -p 6381 -n 1 SCARD all_keywords"

wait $DISCOVERY_PID
