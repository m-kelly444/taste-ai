#!/bin/bash

echo "🔗 Testing System Integration"
echo "============================="

# Test 1: End-to-End Workflow
echo "Test 1: Complete User Workflow"
test_complete_workflow() {
    echo "  Testing complete user journey..."
    
    # Step 1: Authentication
    echo "    Step 1: User authentication"
    TOKEN=$(curl -s -X POST http://localhost:8001/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "chris", "password": "burch"}' | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)
    
    if [ ! -z "$TOKEN" ]; then
        echo "      ✅ Authentication successful"
    else
        echo "      ❌ Authentication failed"
        return 1
    fi
    
    # Step 2: Get current trends
    echo "    Step 2: Fetch market trends"
    TRENDS=$(curl -s http://localhost:8001/api/v1/trends/current)
    
    if echo "$TRENDS" | python3 -c "import sys, json; data=json.load(sys.stdin); exit(0 if 'trends' in data else 1)" 2>/dev/null; then
        echo "      ✅ Trends fetched successfully"
    else
        echo "      ❌ Trends fetch failed"
        return 1
    fi
    
    # Step 3: Analyze aesthetic image
    echo "    Step 3: Analyze brand aesthetic"
    
    # Create brand-style test image
    python3 -c "
from PIL import Image, ImageDraw
img = Image.new('RGB', (300, 200), color='#f5f5dc')
draw = ImageDraw.Draw(img)
draw.rectangle([50, 50, 150, 150], fill='#1e3a5f')
img.save('brand_test.jpg')
"
    
    AESTHETIC_RESULT=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
        -F "file=@brand_test.jpg")
    
    if echo "$AESTHETIC_RESULT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    score = data.get('aesthetic_score', 0)
    confidence = data.get('confidence', 0)
    print(f'      Score: {score:.3f}, Confidence: {confidence:.3f}')
    if score > 0 and confidence > 0:
        exit(0)
    else:
        exit(1)
except:
    exit(1)
" 2>/dev/null; then
        echo "      ✅ Aesthetic analysis successful"
    else
        echo "      ❌ Aesthetic analysis failed"
        rm -f brand_test.jpg
        return 1
    fi
    
    # Step 4: Advanced analysis
    echo "    Step 4: Advanced Burch analysis"
    ADVANCED_RESULT=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic-advanced/score-advanced \
        -F "file=@brand_test.jpg")
    
    if echo "$ADVANCED_RESULT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'burch_analysis' in data and 'dimension_scores' in data:
        burch_score = data['burch_analysis'].get('burch_alignment_score', 0)
        print(f'      Burch alignment: {burch_score:.3f}')
        exit(0)
    else:
        exit(1)
except:
    exit(1)
" 2>/dev/null; then
        echo "      ✅ Advanced analysis successful"
    else
        echo "      ❌ Advanced analysis failed"
    fi
    
    rm -f brand_test.jpg
    echo "  ✅ Complete workflow test PASSED"
}

# Test 2: Data Flow Integration
echo "Test 2: Data Flow Between Components"
test_data_flow() {
    echo "  Testing data persistence and retrieval..."
    
    # Check Redis connectivity and data flow
    echo "    Testing Redis data flow..."
    
    if docker exec taste-ai-redis-1 redis-cli set test_key "test_value" > /dev/null 2>&1; then
        RETRIEVED=$(docker exec taste-ai-redis-1 redis-cli get test_key 2>/dev/null)
        if [ "$RETRIEVED" = "test_value" ]; then
            echo "      ✅ Redis data flow working"
            docker exec taste-ai-redis-1 redis-cli del test_key > /dev/null 2>&1
        else
            echo "      ❌ Redis data retrieval failed"
        fi
    else
        echo "      ❌ Redis data storage failed"
    fi
    
    # Check database integration
    echo "    Testing database integration..."
    
    if docker exec taste-ai-db-1 psql -U user -d tasteai -c "CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY, data TEXT);" > /dev/null 2>&1; then
        if docker exec taste-ai-db-1 psql -U user -d tasteai -c "INSERT INTO test_table (data) VALUES ('test');" > /dev/null 2>&1; then
            RECORD_COUNT=$(docker exec taste-ai-db-1 psql -U user -d tasteai -t -c "SELECT COUNT(*) FROM test_table;" 2>/dev/null | xargs)
            if [ "$RECORD_COUNT" -gt "0" ]; then
                echo "      ✅ Database integration working"
                docker exec taste-ai-db-1 psql -U user -d tasteai -c "DROP TABLE test_table;" > /dev/null 2>&1
            else
                echo "      ❌ Database record retrieval failed"
            fi
        else
            echo "      ❌ Database record insertion failed"
        fi
    else
        echo "      ❌ Database table creation failed"
    fi
}

# Test 3: Service Communication
echo "Test 3: Inter-Service Communication"
test_service_communication() {
    echo "  Testing frontend-backend communication..."
    
    # Test if frontend can reach backend
    FRONTEND_TO_BACKEND=$(docker exec taste-ai-frontend-1 wget -qO- http://backend:8000/health 2>/dev/null || echo "FAILED")
    
    if echo "$FRONTEND_TO_BACKEND" | grep -q "healthy"; then
        echo "      ✅ Frontend can communicate with backend"
    else
        echo "      ❌ Frontend-backend communication failed"
    fi
    
    # Test backend database connectivity
    echo "    Testing backend-database communication..."
    
    DB_HEALTH=$(curl -s http://localhost:8001/health | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data.get('status') == 'healthy':
        print('healthy')
    else:
        print('unhealthy')
except:
    print('error')
" 2>/dev/null)
    
    if [ "$DB_HEALTH" = "healthy" ]; then
        echo "      ✅ Backend-database communication working"
    else
        echo "      ❌ Backend-database communication issues"
    fi
}

# Run integration tests
test_complete_workflow
test_data_flow
test_service_communication

echo "✅ Integration tests completed!"
