#!/bin/bash

echo "⚡ Optimizing Intelligence Performance..."

# Optimize Redis for high-throughput intelligence processing
redis-cli -p 6381 CONFIG SET maxmemory-policy allkeys-lru
redis-cli -p 6381 CONFIG SET save ""  # Disable disk saves for speed
redis-cli -p 6381 CONFIG SET tcp-keepalive 60
redis-cli -p 6381 CONFIG SET timeout 0

# Set intelligence processing priorities
for stream in {1..50}; do
    PID=$(pgrep -f "intelligence stream $stream" | head -1)
    if [ ! -z "$PID" ]; then
        renice -n -10 $PID 2>/dev/null  # Higher priority
    fi
done

# Optimize quantum processing
QP_PIDS=$(pgrep -f "quantum_reasoning_burst.sh")
for pid in $QP_PIDS; do
    renice -n -15 $pid 2>/dev/null  # Highest priority for quantum
done

echo "✅ Intelligence performance optimized"
