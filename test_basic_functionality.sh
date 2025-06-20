#!/bin/bash

echo "🔧 Testing Basic Functionality"
echo "=============================="

# Test 1: Service Health
echo "Test 1: Service Health Checks"
test_service_health() {
    echo "  Testing backend health..."
    if curl -f http://localhost:8001/health; then
        echo "  ✅ Backend health check PASSED"
    else
        echo "  ❌ Backend health check FAILED"
        return 1
    fi
    
    echo "  Testing frontend accessibility..."
    if curl -f http://localhost:3002 > /dev/null 2>&1; then
        echo "  ✅ Frontend accessibility PASSED"
    else
        echo "  ❌ Frontend accessibility FAILED"
        return 1
    fi
    
    echo "  Testing database connection..."
    if docker exec taste-ai-db-1 psql -U user -d tasteai -c "SELECT 1;" > /dev/null 2>&1; then
        echo "  ✅ Database connection PASSED"
    else
        echo "  ❌ Database connection FAILED"
        return 1
    fi
    
    echo "  Testing Redis connection..."
    if docker exec taste-ai-redis-1 redis-cli ping > /dev/null 2>&1; then
        echo "  ✅ Redis connection PASSED"
    else
        echo "  ❌ Redis connection FAILED"
        return 1
    fi
}

# Test 2: Authentication
echo "Test 2: Authentication System"
test_authentication() {
    echo "  Testing login endpoint..."
    
    # Test admin login
    ADMIN_TOKEN=$(curl -s -X POST http://localhost:8001/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": "password"}' | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)
    
    if [ ! -z "$ADMIN_TOKEN" ]; then
        echo "  ✅ Admin authentication PASSED"
        echo "  Token: ${ADMIN_TOKEN:0:20}..."
    else
        echo "  ❌ Admin authentication FAILED"
        return 1
    fi
    
    # Test Chris Burch login
    CHRIS_TOKEN=$(curl -s -X POST http://localhost:8001/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "chris", "password": "burch"}' | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)
    
    if [ ! -z "$CHRIS_TOKEN" ]; then
        echo "  ✅ Chris Burch authentication PASSED"
        echo "  Token: ${CHRIS_TOKEN:0:20}..."
    else
        echo "  ❌ Chris Burch authentication FAILED"
        return 1
    fi
    
    # Test invalid login
    INVALID_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:8001/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "invalid", "password": "wrong"}' -o /dev/null)
    
    if [ "$INVALID_RESPONSE" = "401" ]; then
        echo "  ✅ Invalid login rejection PASSED"
    else
        echo "  ❌ Invalid login rejection FAILED (got $INVALID_RESPONSE)"
        return 1
    fi
}

# Run tests
test_service_health
test_authentication

echo "✅ Basic functionality tests completed!"
