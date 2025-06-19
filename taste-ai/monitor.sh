#!/bin/bash

echo "📊 TASTE.AI - System Monitoring"

check_service() {
    local service=$1
    local url=$2
    
    if curl -sf "$url" > /dev/null 2>&1; then
        echo "✅ $service: HEALTHY"
        return 0
    else
        echo "❌ $service: UNHEALTHY"
        return 1
    fi
}

echo "🔍 Checking services..."

check_service "Frontend" "http://localhost:80"
check_service "Backend" "http://localhost:8000/health"
check_service "Database" "http://localhost:8000/health"

echo ""
echo "📈 Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo ""
echo "💾 Disk Usage:"
df -h | head -2

echo ""
echo "🐳 Container Status:"
docker-compose -f docker-compose.prod.yml ps
