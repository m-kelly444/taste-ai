#!/bin/bash

echo "🌐 Testing API Endpoints"
echo "======================="

# Get authentication token
get_auth_token() {
    curl -s -X POST http://localhost:8001/api/v1/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": "password"}' | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null
}

TOKEN=$(get_auth_token)

# Test 1: Trends API
echo "Test 1: Trends API"
test_trends_api() {
    echo "  Testing current trends endpoint..."
    
    TRENDS_RESPONSE=$(curl -s http://localhost:8001/api/v1/trends/current)
    
    if echo "$TRENDS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print('✅ Current trends' if 'trends' in data else '❌ No trends')" 2>/dev/null; then
        echo "  ✅ Current trends endpoint PASSED"
        
        # Check trend data structure
        echo "$TRENDS_RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
trends = data.get('trends', [])
if trends and len(trends) > 0:
    trend = trends[0]
    required_fields = ['name', 'score', 'category', 'momentum']
    if all(field in trend for field in required_fields):
        print('  ✅ Trend data structure PASSED')
    else:
        print('  ❌ Trend data structure FAILED')
else:
    print('  ❌ No trend data found')
" 2>/dev/null
    else
        echo "  ❌ Current trends endpoint FAILED"
    fi
}

# Test 2: Aesthetic Scoring API
echo "Test 2: Aesthetic Scoring API"
test_aesthetic_api() {
    # Create a test image if it doesn't exist
    if [ ! -f "test_image.jpg" ]; then
        echo "  Creating test image..."
        python3 -c "
from PIL import Image
import numpy as np

# Create a simple test image
img = Image.fromarray(np.random.randint(0, 255, (200, 200, 3), dtype=np.uint8))
img.save('test_image.jpg')
print('  Test image created')
"
    fi
    
    echo "  Testing aesthetic scoring endpoint..."
    
    AESTHETIC_RESPONSE=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
        -F "file=@test_image.jpg")
    
    if echo "$AESTHETIC_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'aesthetic_score' in data and isinstance(data['aesthetic_score'], (int, float)):
        print('  ✅ Aesthetic scoring PASSED')
        print(f'    Score: {data[\"aesthetic_score\"]:.3f}')
        if 'trend_analysis' in data:
            print('  ✅ Trend analysis included')
        if 'confidence' in data:
            print(f'    Confidence: {data[\"confidence\"]:.3f}')
    else:
        print('  ❌ Invalid aesthetic response')
except:
    print('  ❌ Aesthetic scoring FAILED')
" 2>/dev/null; then
        echo "  ✅ Aesthetic API test completed"
    else
        echo "  ❌ Aesthetic API test FAILED"
    fi
    
    # Clean up test image
    rm -f test_image.jpg
}

# Test 3: Advanced Aesthetic API
echo "Test 3: Advanced Aesthetic API"
test_advanced_aesthetic() {
    # Create test image
    python3 -c "
from PIL import Image, ImageDraw
import numpy as np

# Create a more sophisticated test image
img = Image.new('RGB', (400, 300), color='white')
draw = ImageDraw.Draw(img)

# Add some shapes
draw.rectangle([50, 50, 150, 150], fill='blue')
draw.ellipse([200, 100, 300, 200], fill='red')
draw.polygon([(320, 50), (370, 100), (345, 150)], fill='green')

img.save('advanced_test.jpg')
print('Advanced test image created')
"
    
    echo "  Testing advanced aesthetic analysis..."
    
    ADVANCED_RESPONSE=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic-advanced/score-advanced \
        -F "file=@advanced_test.jpg")
    
    if echo "$ADVANCED_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'aesthetic_score' in data:
        print(f'  ✅ Advanced scoring: {data[\"aesthetic_score\"]:.3f}')
        
        # Check for advanced features
        if 'dimension_scores' in data:
            print('  ✅ Dimension scores included')
        if 'burch_analysis' in data:
            print('  ✅ Burch analysis included')
        if 'trend_analysis' in data:
            print('  ✅ Trend analysis included')
        if 'insights' in data:
            print(f'  ✅ Insights provided: {len(data[\"insights\"])} items')
    else:
        print('  ❌ Advanced aesthetic analysis FAILED')
except Exception as e:
    print(f'  ❌ Advanced API error: {e}')
" 2>/dev/null; then
        echo "  ✅ Advanced aesthetic API test completed"
    else
        echo "  ❌ Advanced aesthetic API FAILED"
    fi
    
    rm -f advanced_test.jpg
}

# Test 4: Metrics API
echo "Test 4: Metrics API"
test_metrics_api() {
    echo "  Testing metrics endpoint..."
    
    METRICS_RESPONSE=$(curl -s http://localhost:8001/metrics)
    
    if echo "$METRICS_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'system' in data and 'application' in data:
        print('  ✅ Metrics endpoint PASSED')
        sys_data = data['system']
        app_data = data['application']
        print(f'    CPU: {sys_data.get(\"cpu_usage_percent\", \"N/A\")}%')
        print(f'    Memory: {sys_data.get(\"memory_usage_percent\", \"N/A\")}%')
        print(f'    API Requests: {app_data.get(\"api_requests_total\", \"N/A\")}')
    else:
        print('  ❌ Invalid metrics response')
except:
    print('  ❌ Metrics endpoint FAILED')
" 2>/dev/null; then
        echo "  ✅ Metrics API test completed"
    else
        echo "  ❌ Metrics API FAILED"
    fi
}

# Run API tests
test_trends_api
test_aesthetic_api
test_advanced_aesthetic
test_metrics_api

echo "✅ API endpoint tests completed!"
