#!/bin/bash
set -e

echo "🚀 Starting FULLY FUNCTIONAL Discovery Engine..."

# Ensure Redis is running
cd ../../../
docker-compose up -d redis

echo "⏳ Waiting for Redis..."
sleep 5

echo "🔬 Starting functional discovery..."
cd production/functional_discovery/engines
python3 functional_discovery.py &
DISCOVERY_PID=$!

echo "✅ Functional discovery started with PID: $DISCOVERY_PID"
echo "$DISCOVERY_PID" > ../functional_discovery.pid

echo "🌐 Discovery engine is now:"
echo "  • Discovering actual DNS infrastructure"
echo "  • Finding real search engines"
echo "  • Crawling and extracting all data"
echo "  • Learning patterns dynamically"
echo "  • Building Chris Burch ecosystem map"

wait $DISCOVERY_PID
