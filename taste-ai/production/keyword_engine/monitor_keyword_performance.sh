#!/bin/bash

echo "📊 PRODUCTION Keyword Engine Monitor"
echo "===================================="

while true; do
    clear
    echo "📊 PRODUCTION Keyword Engine - $(date)"
    echo "======================================"
    
    # Total keywords discovered
    TOTAL_KEYWORDS=$(redis-cli -p 6381 -n 1 SCARD all_keywords 2>/dev/null || echo "0")
    echo "🔍 Total Keywords Discovered: $TOTAL_KEYWORDS"
    
    # Active keywords
    ACTIVE_KEYWORDS=$(redis-cli -p 6381 -n 1 SCARD active_keywords 2>/dev/null || echo "0")
    echo "⚡ Active Keywords: $ACTIVE_KEYWORDS"
    
    # Latest optimization cycle
    LATEST_OPTIMIZATION=$(redis-cli -p 6381 -n 1 KEYS "optimization_report:*" | wc -l 2>/dev/null || echo "0")
    echo "🎯 Optimization Cycles: $LATEST_OPTIMIZATION"
    
    echo ""
    echo "🏆 Top 10 Keywords (by usage):"
    redis-cli -p 6381 -n 1 SMEMBERS active_keywords 2>/dev/null | head -10 | while read keyword; do
        echo "  • $keyword"
    done
    
    echo ""
    echo "⚡ System Status:"
    if pgrep -f "live_keyword_engine.py" > /dev/null; then
        echo "  ✅ Keyword Discovery: RUNNING"
    else
        echo "  ❌ Keyword Discovery: STOPPED"
    fi
    
    if pgrep -f "live_optimizer.py" > /dev/null; then
        echo "  ✅ Keyword Optimizer: RUNNING"
    else
        echo "  ❌ Keyword Optimizer: STOPPED"
    fi
    
    echo ""
    echo "📈 Discovery Rate: $((TOTAL_KEYWORDS / 60)) keywords/hour average"
    echo "📊 Press Ctrl+C to exit | Updates every 10 seconds"
    
    sleep 10
done
