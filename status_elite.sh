#!/bin/bash
clear
echo "📊 TASTE.AI Elite Status"
echo "========================"

# System health
if curl -sf http://localhost:8001/health >/dev/null; then
    echo "🟢 System: OPERATIONAL"
    
    # Get intelligence level
    INTEL=$(docker exec $(docker ps -qf "name=redis") redis-cli get intelligence_level 2>/dev/null || echo "0.000")
    echo "🧠 Intelligence Level: $INTEL"
    
    # Pattern count
    PATTERNS=$(docker exec $(docker ps -qf "name=redis") redis-cli keys 'pattern:*' | wc -l 2>/dev/null || echo "0")
    echo "🔍 Discovered Patterns: $PATTERNS"
    
    # Chris optimization
    CHRIS_OPT=$(docker exec $(docker ps -qf "name=redis") redis-cli get chris_optimization_score 2>/dev/null || echo "0.000")
    echo "👑 Chris Optimization: $(echo "$CHRIS_OPT * 100" | bc -l 2>/dev/null | cut -c1-5)%"
    
else
    echo "🔴 System: OFFLINE"
fi

echo ""
echo "🎯 Quick Actions:"
echo "   Launch:  ./launch_elite.sh"
echo "   Stop:    docker-compose -f docker-compose.elite.yml down"
echo "   Logs:    docker-compose -f docker-compose.elite.yml logs -f"
