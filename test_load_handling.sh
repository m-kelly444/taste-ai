#!/bin/bash

echo "💪 Testing Load Handling"
echo "======================="

# Test 1: Stress Testing
echo "Test 1: API Stress Test"
test_api_stress() {
    echo "  Performing API stress test..."
    
    # Create test image
    python3 -c "
from PIL import Image
import numpy as np
img = Image.fromarray(np.random.randint(0, 255, (150, 150, 3), dtype=np.uint8))
img.save('stress_test.jpg')
"
    
    echo "  Launching 10 concurrent requests..."
    
    START_TIME=$(date +%s)
    
    # Launch multiple concurrent requests
    for i in {1..10}; do
        (
            curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
                -F "file=@stress_test.jpg" \
                -w "Request $i: %{http_code} %{time_total}s\n" \
                -o "stress_response_$i.json"
        ) &
    done
    
    wait
    
    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))
    
    echo "  Stress test completed in ${TOTAL_TIME}s"
    
    # Analyze results
    SUCCESS_COUNT=0
    TOTAL_RESPONSE_TIME=0
    
    for i in {1..10}; do
        if [ -f "stress_response_$i.json" ]; then
            if python3 -c "
import json
try:
    with open('stress_response_$i.json', 'r') as f:
        data = json.load(f)
    exit(0 if 'aesthetic_score' in data else 1)
except:
    exit(1)
" 2>/dev/null; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            fi
        fi
    done
    
    echo "    Successful requests: $SUCCESS_COUNT/10"
    echo "    Average time per batch: ${TOTAL_TIME}s"
    
    if [ $SUCCESS_COUNT -ge 8 ]; then
        echo "  ✅ Stress test PASSED"
    else
        echo "  ❌ Stress test FAILED"
    fi
    
    # Clean up
    rm -f stress_test.jpg stress_response_*.json
}

# Test 2: Memory Leak Detection
echo "Test 2: Memory Leak Detection"
test_memory_leaks() {
    echo "  Monitoring memory usage over multiple requests..."
    
    # Create test image
    python3 -c "
from PIL import Image
import numpy as np
img = Image.fromarray(np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8))
img.save('memory_test.jpg')
"
    
    # Get initial memory usage
    INITIAL_MEMORY=$(curl -s http://localhost:8001/metrics | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data['system']['memory_usage_percent'])
except:
    print('0')
" 2>/dev/null)
    
    echo "    Initial memory usage: $INITIAL_MEMORY%"
    
    # Perform 20 requests
    echo "    Performing 20 sequential requests..."
    for i in {1..20}; do
        curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
            -F "file=@memory_test.jpg" -o /dev/null
    done
    
    # Check memory usage after requests
    FINAL_MEMORY=$(curl -s http://localhost:8001/metrics | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data['system']['memory_usage_percent'])
except:
    print('0')
" 2>/dev/null)
    
    echo "    Final memory usage: $FINAL_MEMORY%"
    
    # Check for significant memory increase
    python3 -c "
try:
    initial = float('$INITIAL_MEMORY')
    final = float('$FINAL_MEMORY')
    increase = final - initial
    
    print(f'    Memory increase: {increase:.1f}%')
    
    if increase < 10.0:  # Less than 10% increase
        print('  ✅ No significant memory leak detected')
    else:
        print('  ⚠️  Potential memory leak detected')
except:
    print('  ❓ Could not determine memory usage')
"
    
    rm -f memory_test.jpg
}

# Run load tests
test_api_stress
test_memory_leaks

echo "✅ Load handling tests completed!"
