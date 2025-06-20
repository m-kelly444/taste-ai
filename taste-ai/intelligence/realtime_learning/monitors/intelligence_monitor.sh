#!/bin/bash

# Intelligence System Monitor
# Continuously monitors the learning engine performance

echo "📊 TASTE.AI Intelligence Monitor"
echo "==============================="

while true; do
    clear
    echo "📊 TASTE.AI Intelligence Monitor - $(date)"
    echo "=========================================="
    
    # Check Redis for learning metrics
    echo "🧠 Learning Engine Status:"
    
    # Model version
    MODEL_VERSION=$(redis-cli -p 6381 GET model_version 2>/dev/null || echo "0")
    echo "  Current Model Version: $MODEL_VERSION"
    
    # Learning queue size
    QUEUE_SIZE=$(redis-cli -p 6381 LLEN learning_queue 2>/dev/null || echo "0")
    echo "  Learning Queue Size: $QUEUE_SIZE"
    
    # Recent updates
    RECENT_UPDATES=$(redis-cli -p 6381 LLEN learning_history 2>/dev/null || echo "0")
    echo "  Learning History: $RECENT_UPDATES entries"
    
    # Chris interactions today
    CHRIS_INTERACTIONS=$(redis-cli -p 6381 LLEN chris_interactions 2>/dev/null || echo "0")
    echo "  Pending Chris Interactions: $CHRIS_INTERACTIONS"
    
    echo ""
    echo "⚡ System Performance:"
    
    # Process status
    if pgrep -f "continuous_learner.py" > /dev/null; then
        echo "  ✅ Continuous Learning Engine: RUNNING"
    else
        echo "  ❌ Continuous Learning Engine: STOPPED"
    fi
    
    if pgrep -f "data_ingestion" > /dev/null; then
        echo "  ✅ Data Ingestion: RUNNING"
    else
        echo "  ❌ Data Ingestion: STOPPED"
    fi
    
    # Memory usage
    MEMORY_USAGE=$(ps aux | grep -E "(continuous_learner|data_ingestion)" | awk '{sum += $6} END {print sum/1024 " MB"}')
    echo "  Memory Usage: $MEMORY_USAGE"
    
    echo ""
    echo "🎯 Intelligence Metrics:"
    
    # Get latest learning stats from Redis
    LATEST_STATS=$(redis-cli -p 6381 LINDEX learning_history 0 2>/dev/null)
    if [ ! -z "$LATEST_STATS" ]; then
        echo "  Latest Learning Batch:"
        echo "$LATEST_STATS" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'    Updates Processed: {data.get(\"update_count\", 0)}')
    print(f'    Avg Confidence: {data.get(\"avg_confidence\", 0):.3f}')
    print(f'    Total Impact: {data.get(\"total_impact\", 0):.3f}')
    print(f'    Sources: {data.get(\"sources\", [])}')
except:
    print('    No recent data')
"
    fi
    
    echo ""
    echo "📈 Press Ctrl+C to exit | Updates every 10 seconds"
    
    sleep 10
done
