#!/bin/bash

echo "⚡ TASTE.AI - Quick Working Test"
echo "==============================="
echo ""
echo "This script ensures everything is working and runs focused tests"

cd taste-ai

# Check if diagnose script was run first
if [ ! -f ".backend_pid" ] || [ ! -f ".frontend_pid" ]; then
    echo "🔧 Services not detected. Running diagnosis first..."
    echo ""
    chmod +x diagnose_and_fix.sh
    ./diagnose_and_fix.sh
    echo ""
    echo "⏰ Waiting for services to stabilize..."
    sleep 10
fi

# Get PIDs if available
BACKEND_PID=$(cat .backend_pid 2>/dev/null || echo "")
FRONTEND_PID=$(cat .frontend_pid 2>/dev/null || echo "")

echo "🔍 Checking Service Status..."
echo "============================="

# Test services
BACKEND_OK=false
FRONTEND_OK=false
DATABASE_OK=false
REDIS_OK=false

# Check Backend
if curl -sf http://localhost:8001/health > /dev/null 2>&1; then
    echo "✅ Backend API: RESPONDING"
    BACKEND_OK=true
    
    # Get health details
    HEALTH_RESPONSE=$(curl -s http://localhost:8001/health)
    echo "   Status: $(echo "$HEALTH_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('status', 'healthy'))" 2>/dev/null || echo 'healthy')"
else
    echo "❌ Backend API: NOT RESPONDING"
    echo "   URL: http://localhost:8001/health"
fi

# Check Frontend
if curl -sf http://localhost:3002 > /dev/null 2>&1; then
    echo "✅ Frontend: RESPONDING"
    FRONTEND_OK=true
else
    echo "❌ Frontend: NOT RESPONDING"
    echo "   URL: http://localhost:3002"
fi

# Check Database
if docker exec taste-ai-db-1 psql -U user -d tasteai -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Database: CONNECTED"
    DATABASE_OK=true
else
    echo "❌ Database: NOT CONNECTED"
fi

# Check Redis
if docker exec taste-ai-redis-1 redis-cli ping 2>/dev/null | grep -q "PONG"; then
    echo "✅ Redis: CONNECTED"
    REDIS_OK=true
else
    echo "❌ Redis: NOT CONNECTED"
fi

echo ""
echo "🧪 Running Core Functionality Tests..."
echo "======================================"

TESTS_PASSED=0
TESTS_TOTAL=0

# Test 1: Authentication
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ "$BACKEND_OK" = true ]; then
    echo "🔐 Testing Authentication..."
    
    AUTH_RESPONSE=$(curl -s -X POST http://localhost:8001/api/v1/auth/login \
      -H "Content-Type: application/json" \
      -d '{"username": "admin", "password": "password"}' 2>/dev/null)
    
    if echo "$AUTH_RESPONSE" | grep -q "access_token"; then
        echo "   ✅ Login successful"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Extract token for further tests
        TOKEN=$(echo "$AUTH_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)
        
    else
        echo "   ❌ Login failed"
        echo "   Response: $AUTH_RESPONSE"
    fi
else
    echo "🔐 Authentication: SKIPPED (Backend not responding)"
fi

# Test 2: API Endpoints
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ "$BACKEND_OK" = true ] && [ ! -z "$TOKEN" ]; then
    echo "📊 Testing API Endpoints..."
    
    # Test trends endpoint
    TRENDS_RESPONSE=$(curl -s http://localhost:8001/api/v1/trends/current 2>/dev/null)
    
    if echo "$TRENDS_RESPONSE" | grep -q "trends"; then
        echo "   ✅ Trends API working"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        TREND_COUNT=$(echo "$TRENDS_RESPONSE" | python3 -c "import sys, json; print(len(json.load(sys.stdin).get('trends', [])))" 2>/dev/null || echo "0")
        echo "   📈 Found $TREND_COUNT trends"
        
    else
        echo "   ❌ Trends API failed"
    fi
else
    echo "📊 API Endpoints: SKIPPED (Backend or auth not working)"
fi

# Test 3: Database Operations
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ "$DATABASE_OK" = true ]; then
    echo "💾 Testing Database Operations..."
    
    # Test write and read
    WRITE_RESULT=$(docker exec taste-ai-db-1 psql -U user -d tasteai -c "CREATE TABLE IF NOT EXISTS test_quick (id SERIAL, data TEXT); INSERT INTO test_quick (data) VALUES ('test'); SELECT COUNT(*) FROM test_quick;" 2>/dev/null)
    
    if echo "$WRITE_RESULT" | grep -E "[1-9]"; then
        echo "   ✅ Database read/write working"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Cleanup
        docker exec taste-ai-db-1 psql -U user -d tasteai -c "DROP TABLE IF EXISTS test_quick;" > /dev/null 2>&1
    else
        echo "   ❌ Database operations failed"
    fi
else
    echo "💾 Database Operations: SKIPPED (Database not connected)"
fi

# Test 4: Cache Operations
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ "$REDIS_OK" = true ]; then
    echo "🔴 Testing Cache Operations..."
    
    # Test Redis set/get
    docker exec taste-ai-redis-1 redis-cli SET test_quick_key "test_value" > /dev/null 2>&1
    REDIS_VALUE=$(docker exec taste-ai-redis-1 redis-cli GET test_quick_key 2>/dev/null)
    
    if [ "$REDIS_VALUE" = "test_value" ]; then
        echo "   ✅ Cache read/write working"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Cleanup
        docker exec taste-ai-redis-1 redis-cli DEL test_quick_key > /dev/null 2>&1
    else
        echo "   ❌ Cache operations failed"
    fi
else
    echo "🔴 Cache Operations: SKIPPED (Redis not connected)"
fi

# Test 5: Frontend Integration
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ "$FRONTEND_OK" = true ]; then
    echo "🌐 Testing Frontend Integration..."
    
    # Check if frontend serves content
    FRONTEND_CONTENT=$(curl -s http://localhost:3002 2>/dev/null)
    
    if echo "$FRONTEND_CONTENT" | grep -i "taste.ai\|root\|html"; then
        echo "   ✅ Frontend serving content"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Check if frontend can proxy to backend
        PROXY_TEST=$(curl -s http://localhost:3002/api/health 2>/dev/null)
        if echo "$PROXY_TEST" | grep -q "healthy"; then
            echo "   ✅ Frontend-Backend proxy working"
        else
            echo "   ⚠️  Frontend-Backend proxy not configured"
        fi
        
    else
        echo "   ❌ Frontend not serving expected content"
    fi
else
    echo "🌐 Frontend Integration: SKIPPED (Frontend not responding)"
fi

# Test 6: ML Models (if available)
TESTS_TOTAL=$((TESTS_TOTAL + 1))
echo "🧠 Testing ML Models..."

if [ -f "ml/data/models/burch_aesthetic_model.pth" ]; then
    echo "   ✅ Burch aesthetic model found"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    
    if [ -f "ml/evaluation/reports/model_evaluation_report.json" ]; then
        CORRELATION=$(python3 -c "
import json
try:
    with open('ml/evaluation/reports/model_evaluation_report.json', 'r') as f:
        data = json.load(f)
    print(f\"{data['models']['aesthetic_scorer']['performance']['test_correlation']:.3f}\")
except:
    print('N/A')
" 2>/dev/null)
        echo "   📊 Model correlation: $CORRELATION"
    fi
else
    echo "   ⚠️  ML models not trained yet (run: ./advanced_ml_training.sh)"
fi

echo ""
echo "📊 TEST RESULTS SUMMARY"
echo "======================="
echo ""

# Calculate success percentage
if [ $TESTS_TOTAL -gt 0 ]; then
    SUCCESS_PERCENTAGE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
else
    SUCCESS_PERCENTAGE=0
fi

echo "Tests Passed: $TESTS_PASSED / $TESTS_TOTAL"
echo "Success Rate: $SUCCESS_PERCENTAGE%"
echo ""

# Determine overall status
if [ $SUCCESS_PERCENTAGE -ge 80 ]; then
    echo "🎉 STATUS: EXCELLENT! System is working well!"
    echo ""
    echo "✅ Core functionality operational"
    echo "✅ Ready for comprehensive testing"
    echo "✅ All major components responding"
    
elif [ $SUCCESS_PERCENTAGE -ge 60 ]; then
    echo "⚠️  STATUS: GOOD! System mostly working with minor issues"
    echo ""
    echo "✅ Essential services operational"
    echo "⚠️  Some components need attention"
    echo "👍 Good enough for basic testing"
    
elif [ $SUCCESS_PERCENTAGE -ge 40 ]; then
    echo "🔧 STATUS: PARTIAL! System has significant issues"
    echo ""
    echo "⚠️  Core services have problems"
    echo "❌ Multiple components failing"
    echo "🛠️  Needs repair before full testing"
    
else
    echo "❌ STATUS: CRITICAL! System needs major repairs"
    echo ""
    echo "❌ Most components not working"
    echo "🚨 Cannot proceed with testing"
    echo "🔧 Run diagnosis and fix first"
fi

echo ""
echo "🌐 Quick Access Links:"
echo "====================="

if [ "$FRONTEND_OK" = true ]; then
    echo "🎨 Frontend Dashboard: http://localhost:3002"
else
    echo "❌ Frontend Dashboard: OFFLINE"
fi

if [ "$BACKEND_OK" = true ]; then
    echo "🔧 Backend API: http://localhost:8001"
    echo "📚 API Documentation: http://localhost:8001/api/docs"
    echo "💚 Health Check: http://localhost:8001/health"
else
    echo "❌ Backend API: OFFLINE"
fi

echo ""
echo "📋 Component Status Overview:"
echo "============================"
echo "Backend API:    $([ "$BACKEND_OK" = true ] && echo "✅ Online" || echo "❌ Offline")"
echo "Frontend UI:    $([ "$FRONTEND_OK" = true ] && echo "✅ Online" || echo "❌ Offline")"
echo "Database:       $([ "$DATABASE_OK" = true ] && echo "✅ Connected" || echo "❌ Disconnected")"
echo "Cache (Redis):  $([ "$REDIS_OK" = true ] && echo "✅ Connected" || echo "❌ Disconnected")"

echo ""
echo "🛠️  Troubleshooting:"
echo "==================="

if [ "$BACKEND_OK" = false ]; then
    echo "Backend Issues:"
    echo "  • Check logs: tail -f logs/backend.log"
    echo "  • Try restarting: kill \$(cat .backend_pid 2>/dev/null) && cd backend && source venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8001 &"
    echo "  • Check dependencies: cd backend && source venv/bin/activate && pip install -r requirements_working.txt"
fi

if [ "$FRONTEND_OK" = false ]; then
    echo "Frontend Issues:"
    echo "  • Check logs: tail -f logs/frontend.log"
    echo "  • Try restarting: kill \$(cat .frontend_pid 2>/dev/null) && cd frontend && npm run dev &"
    echo "  • Check dependencies: cd frontend && npm install"
fi

if [ "$DATABASE_OK" = false ]; then
    echo "Database Issues:"
    echo "  • Restart Docker: docker-compose -f docker-compose.services-only.yml down && docker-compose -f docker-compose.services-only.yml up -d"
    echo "  • Check logs: docker logs taste-ai-db-1"
fi

if [ "$REDIS_OK" = false ]; then
    echo "Redis Issues:"
    echo "  • Restart Docker: docker-compose -f docker-compose.services-only.yml restart redis"
    echo "  • Check logs: docker logs taste-ai-redis-1"
fi

echo ""
echo "🚀 Next Steps:"
echo "=============="

if [ $SUCCESS_PERCENTAGE -ge 60 ]; then
    echo "✅ System ready for testing!"
    echo ""
    echo "Recommended actions:"
    echo "  1. 🌐 Open frontend: http://localhost:3002"
    echo "  2. 📚 Explore API docs: http://localhost:8001/api/docs"
    echo "  3. 🧪 Run full test suite: ./comprehensive_test_suite.sh"
    echo "  4. 🎨 Test aesthetic scoring (upload images)"
    echo "  5. 📊 View trend analysis dashboard"
    
    if [ ! -f "ml/data/models/burch_aesthetic_model.pth" ]; then
        echo ""
        echo "💡 Optional: Train ML models for enhanced functionality"
        echo "    ./advanced_ml_training.sh"
    fi
    
else
    echo "🔧 System needs repairs!"
    echo ""
    echo "Recommended actions:"
    echo "  1. 🔍 Run diagnosis: ./diagnose_and_fix.sh"
    echo "  2. 📋 Check service logs in logs/ directory"
    echo "  3. 🔄 Restart failed components"
    echo "  4. ⚡ Re-run this test: ./quick_working_test.sh"
fi

echo ""
echo "📊 System Metrics:"
echo "=================="

if [ "$BACKEND_OK" = true ]; then
    METRICS_RESPONSE=$(curl -s http://localhost:8001/metrics 2>/dev/null)
    if [ ! -z "$METRICS_RESPONSE" ]; then
        CPU_USAGE=$(echo "$METRICS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'{data[\"system\"][\"cpu_usage_percent\"]}%')" 2>/dev/null || echo "N/A")
        MEMORY_USAGE=$(echo "$METRICS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'{data[\"system\"][\"memory_usage_percent\"]}%')" 2>/dev/null || echo "N/A")
        API_REQUESTS=$(echo "$METRICS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[\"application\"][\"api_requests_total\"])" 2>/dev/null || echo "N/A")
        
        echo "CPU Usage:      $CPU_USAGE"
        echo "Memory Usage:   $MEMORY_USAGE"
        echo "API Requests:   $API_REQUESTS"
    else
        echo "Metrics not available"
    fi
else
    echo "Backend offline - no metrics available"
fi

echo ""
echo "🎯 TASTE.AI Quick Test Complete!"

# If services are running well, offer to keep them running
if [ $SUCCESS_PERCENTAGE -ge 60 ]; then
    echo ""
    echo "Services are running. Press Ctrl+C to stop, or leave running for testing."
    echo ""
    
    # Cleanup function
    cleanup() {
        echo ""
        echo "🛑 Stopping services..."
        
        if [ ! -z "$BACKEND_PID" ]; then
            kill $BACKEND_PID 2>/dev/null
        fi
        if [ ! -z "$FRONTEND_PID" ]; then
            kill $FRONTEND_PID 2>/dev/null
        fi
        
        # Try to kill by saved PID files
        [ -f ".backend_pid" ] && kill $(cat .backend_pid) 2>/dev/null
        [ -f ".frontend_pid" ] && kill $(cat .frontend_pid) 2>/dev/null
        
        docker-compose -f docker-compose.services-only.yml down
        
        # Clean up PID files
        rm -f .backend_pid .frontend_pid
        
        echo "✅ All services stopped"
        exit 0
    }
    
    trap cleanup INT TERM
    
    # Keep script running to maintain trap
    while true; do
        sleep 60
        # Quick health check every minute
        if ! curl -sf http://localhost:8001/health > /dev/null 2>&1; then
            echo "⚠️  Backend health check failed at $(date)"
        fi
    done
else
    echo ""
    echo "Fix the issues above and run this test again!"
fi