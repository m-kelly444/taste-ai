#!/bin/bash

echo "📊 TASTE.AI - System Status Check"
echo "================================="
echo "$(date)"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Docker services
echo "🐳 Docker Services:"
if docker-compose -f docker-compose.production.yml ps --services --filter "status=running" >/dev/null 2>&1; then
    docker-compose -f docker-compose.production.yml ps
else
    echo -e "${RED}❌ No services running${NC}"
fi

echo ""

# Check service health
echo "🔍 Service Health:"

# Backend
if curl -s http://localhost:8000/health >/dev/null 2>&1; then
    echo -e "  Backend:    ${GREEN}✅ Healthy${NC}"
    
    # Test auth
    AUTH_TEST=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": "password"}' 2>/dev/null || echo "")
    
    if echo "$AUTH_TEST" | grep -q "access_token"; then
        echo -e "  Auth:       ${GREEN}✅ Working${NC}"
    else
        echo -e "  Auth:       ${RED}❌ Failed${NC}"
    fi
else
    echo -e "  Backend:    ${RED}❌ Offline${NC}"
fi

# Frontend
if curl -s http://localhost:3002 >/dev/null 2>&1; then
    echo -e "  Frontend:   ${GREEN}✅ Online${NC}"
else
    echo -e "  Frontend:   ${RED}❌ Offline${NC}"
fi

# Database
if docker exec $(docker-compose -f docker-compose.production.yml ps -q db) pg_isready -U user -d tasteai >/dev/null 2>&1; then
    echo -e "  Database:   ${GREEN}✅ Connected${NC}"
else
    echo -e "  Database:   ${RED}❌ Not Connected${NC}"
fi

# Redis
if docker exec $(docker-compose -f docker-compose.production.yml ps -q redis) redis-cli ping >/dev/null 2>&1; then
    echo -e "  Redis:      ${GREEN}✅ Connected${NC}"
else
    echo -e "  Redis:      ${RED}❌ Not Connected${NC}"
fi

echo ""

# Performance metrics
echo "📈 Performance:"
if curl -s http://localhost:8000/metrics >/dev/null 2>&1; then
    METRICS=$(curl -s http://localhost:8000/metrics)
    
    if command -v python3 >/dev/null 2>&1; then
        echo "$METRICS" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'  CPU Usage:     {data[\"system\"][\"cpu_usage_percent\"]}%')
    print(f'  Memory Usage:  {data[\"system\"][\"memory_usage_percent\"]}%')
    print(f'  API Requests:  {data[\"application\"][\"api_requests_total\"]}')
    print(f'  ML Inferences: {data[\"application\"][\"ml_inferences_total\"]}')
except:
    print('  Metrics unavailable')
" 2>/dev/null || echo "  Metrics parsing failed"
    else
        echo "  Python not available for metrics parsing"
    fi
else
    echo "  Metrics endpoint unavailable"
fi

echo ""

# Quick test
echo "🧪 Quick API Test:"
if [ -f "test-images/test-image.jpg" ]; then
    TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": "password"}' 2>/dev/null | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null || echo "")
    
    if [ ! -z "$TOKEN" ]; then
        SCORE=$(curl -s -X POST http://localhost:8000/api/v1/aesthetic/score \
            -H "Authorization: Bearer $TOKEN" \
            -F "file=@test-images/test-image.jpg" 2>/dev/null | \
            python3 -c "import sys, json; data=json.load(sys.stdin); print(f'{data[\"aesthetic_score\"]*100:.1f}%')" 2>/dev/null || echo "Failed")
        
        if [ "$SCORE" != "Failed" ]; then
            echo -e "  Image Analysis: ${GREEN}✅ Working (Score: $SCORE)${NC}"
        else
            echo -e "  Image Analysis: ${RED}❌ Failed${NC}"
        fi
    else
        echo -e "  Image Analysis: ${RED}❌ Auth failed${NC}"
    fi
else
    echo -e "  Image Analysis: ${YELLOW}⚠️ No test image${NC}"
fi

echo ""

# Access info
echo "🌐 Access Information:"
echo "  Frontend:    http://localhost:3002"
echo "  Backend:     http://localhost:8000"
echo "  API Docs:    http://localhost:8000/api/docs"
echo "  Credentials: admin / password"

echo ""

# Useful commands
echo "🛠️ Management Commands:"
echo "  Restart:  docker-compose -f docker-compose.production.yml restart"
echo "  Logs:     docker-compose -f docker-compose.production.yml logs -f"
echo "  Stop:     docker-compose -f docker-compose.production.yml down"
echo "  Rebuild:  ./production_deploy.sh"