#!/bin/bash
set -e

echo "🧠 Starting TASTE.AI Intelligence System"
echo "========================================"

# Ensure Redis is running for intelligence data
echo "🔴 Starting Redis for intelligence..."
cd taste-ai
docker-compose up -d redis

# Wait for Redis
sleep 5

echo "🚀 Starting Intelligence Processes..."

# Start learning controller in background
cd intelligence/realtime_learning/pipelines
python3 learning_controller.py &
LEARNING_PID=$!

echo "📊 Intelligence system started with PID: $LEARNING_PID"
echo "💡 Run './intelligence/realtime_learning/monitors/intelligence_monitor.sh' to monitor"
echo "🛑 Kill process $LEARNING_PID to stop"

# Store PID for cleanup
echo $LEARNING_PID > ../../../intelligence_system.pid

wait $LEARNING_PID
