#!/bin/bash

echo "⚡ Testing Performance"
echo "===================="

# Test 1: Response Time
echo "Test 1: API Response Times"
test_response_times() {
    echo "  Measuring API response times..."
    
    # Test health endpoint
    HEALTH_TIME=$(curl -w "%{time_total}" -s http://localhost:8001/health -o /dev/null)
    echo "    Health endpoint: ${HEALTH_TIME}s"
    
    # Test trends endpoint
    TRENDS_TIME=$(curl -w "%{time_total}" -s http://localhost:8001/api/v1/trends/current -o /dev/null)
    echo "    Trends endpoint: ${TRENDS_TIME}s"
    
    # Validate response times
    python3 -c "
health_time = float('$HEALTH_TIME')
trends_time = float('$TRENDS_TIME')

if health_time < 1.0:
    print('  ✅ Health endpoint response time acceptable')
else:
    print('  ⚠️  Health endpoint slow: {:.3f}s'.format(health_time))

if trends_time < 3.0:
    print('  ✅ Trends endpoint response time acceptable')
else:
    print('  ⚠️  Trends endpoint slow: {:.3f}s'.format(trends_time))
"
}

# Test 2: Concurrent Requests
echo "Test 2: Concurrent Request Handling"
test_concurrent_requests() {
    echo "  Testing concurrent request handling..."
    
    # Create a simple test image
    python3 -c "
from PIL import Image
import numpy as np
img = Image.fromarray(np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8))
img.save('perf_test.jpg')
"
    
    # Launch 5 concurrent requests
    echo "  Launching 5 concurrent aesthetic scoring requests..."
    
    for i in {1..5}; do
        curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
            -F "file=@perf_test.jpg" \
            -w "Request $i: %{time_total}s\n" \
            -o "response_$i.json" &
    done
    
    wait
    
    # Check results
    echo "  Analyzing concurrent request results..."
    
    SUCCESS_COUNT=0
    for i in {1..5}; do
        if [ -f "response_$i.json" ]; then
            if python3 -c "
import json
try:
    with open('response_$i.json', 'r') as f:
        data = json.load(f)
    if 'aesthetic_score' in data:
        print('Request $i: SUCCESS')
        exit(0)
    else:
        print('Request $i: FAILED - no score')
        exit(1)
except:
    print('Request $i: FAILED - invalid JSON')
    exit(1)
" 2>/dev/null; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            fi
        fi
    done
    
    echo "    Successful requests: $SUCCESS_COUNT/5"
    
    if [ $SUCCESS_COUNT -ge 4 ]; then
        echo "  ✅ Concurrent request handling PASSED"
    else
        echo "  ❌ Concurrent request handling FAILED"
    fi
    
    # Clean up
    rm -f perf_test.jpg response_*.json
}

# Test 3: Memory Usage
echo "Test 3: Memory Usage Monitoring"
test_memory_usage() {
    echo "  Checking system memory usage..."
    
    MEMORY_STATS=$(curl -s http://localhost:8001/metrics | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    system = data.get('system', {})
    print(f'CPU: {system.get(\"cpu_usage_percent\", \"N/A\")}%')
    print(f'Memory: {system.get(\"memory_usage_percent\", \"N/A\")}%')
    
    mem_percent = system.get('memory_usage_percent', 0)
    if isinstance(mem_percent, (int, float)) and mem_percent < 80:
        print('Memory usage acceptable')
    else:
        print('High memory usage detected')
except:
    print('Could not get memory stats')
" 2>/dev/null)
    
    echo "    $MEMORY_STATS"
    
    if echo "$MEMORY_STATS" | grep -q "Memory usage acceptable"; then
        echo "  ✅ Memory usage within acceptable limits"
    else
        echo "  ⚠️  Memory usage may be high"
    fi
}

# Run performance tests
test_response_times
test_concurrent_requests
test_memory_usage

echo "✅ Performance tests completed!"
