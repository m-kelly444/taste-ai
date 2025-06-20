#!/bin/bash

while true; do
    clear
    echo "Intelligence Growth Monitor - $(date)"
    echo "======================================"
    
    INTELLIGENCE=$(redis-cli -p 6381 -n 3 GET previous_intelligence 2>/dev/null || echo "0.0000")
    echo "Current Intelligence Level: $INTELLIGENCE"
    
    PATTERNS=$(redis-cli -p 6381 -n 3 KEYS "validated_pattern:*" | wc -l 2>/dev/null || echo "0")
    echo "Discovered Patterns: $PATTERNS"
    
    CORRELATIONS=$(redis-cli -p 6381 -n 3 KEYS "correlation:*" | wc -l 2>/dev/null || echo "0")
    echo "Learned Correlations: $CORRELATIONS"
    
    CYCLES=$(redis-cli -p 6381 -n 3 LLEN intelligence_growth_history 2>/dev/null || echo "0")
    echo "Processing Cycles: $CYCLES"
    
    echo ""
    echo "Recent Intelligence Growth:"
    redis-cli -p 6381 -n 3 LRANGE intelligence_growth_history 0 4 2>/dev/null | while read line; do
        echo "  $line" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'  {data[\"timestamp\"]}: Intelligence {data[\"current_intelligence\"]:.4f} (Growth: {data[\"growth_rate\"]:.6f})')
except:
    pass
" 2>/dev/null || echo "  $line"
    done
    
    echo ""
    if pgrep -f "realtime_processor.py" > /dev/null; then
        echo "Status: LEARNING AND GROWING"
    else
        echo "Status: STOPPED"
    fi
    
    sleep 10
done
