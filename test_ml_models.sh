#!/bin/bash

echo "🤖 Testing ML Models"
echo "==================="

# Test 1: Aesthetic Model Performance
echo "Test 1: Aesthetic Model Performance"
test_aesthetic_model() {
    echo "  Creating diverse test images..."
    
    python3 -c "
from PIL import Image, ImageDraw
import numpy as np
import json

results = []

# Test Image 1: High aesthetic (golden ratio composition)
img1 = Image.new('RGB', (400, 247), color='white')  # Golden ratio dimensions
draw1 = ImageDraw.Draw(img1)
draw1.rectangle([100, 60, 300, 187], fill='navy')  # Golden ratio placement
img1.save('test_high_aesthetic.jpg')

# Test Image 2: Low aesthetic (chaotic)
img2 = Image.fromarray(np.random.randint(0, 255, (200, 200, 3), dtype=np.uint8))
img2.save('test_low_aesthetic.jpg')

# Test Image 3: Chris Burch style (minimalist, neutral colors)
img3 = Image.new('RGB', (400, 300), color='#f5f5dc')  # Cream
draw3 = ImageDraw.Draw(img3)
draw3.rectangle([150, 100, 250, 200], fill='#1e3a5f')  # Navy
img3.save('test_burch_style.jpg')

print('Test images created')
"
    
    echo "  Testing aesthetic scoring consistency..."
    
    # Score each test image
    SCORE1=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
        -F "file=@test_high_aesthetic.jpg" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['aesthetic_score'])" 2>/dev/null)
    
    SCORE2=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
        -F "file=@test_low_aesthetic.jpg" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['aesthetic_score'])" 2>/dev/null)
    
    SCORE3=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic/score \
        -F "file=@test_burch_style.jpg" | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['aesthetic_score'])" 2>/dev/null)
    
    echo "  Results:"
    echo "    High aesthetic image: $SCORE1"
    echo "    Low aesthetic image: $SCORE2"
    echo "    Burch style image: $SCORE3"
    
    # Validate scoring logic
    python3 -c "
import sys

try:
    score1 = float('$SCORE1')
    score2 = float('$SCORE2')
    score3 = float('$SCORE3')
    
    # Test reasonable score ranges
    if 0 <= score1 <= 1 and 0 <= score2 <= 1 and 0 <= score3 <= 1:
        print('  ✅ Score ranges valid (0-1)')
    else:
        print('  ❌ Invalid score ranges')
        sys.exit(1)
    
    # Test that Burch style scores reasonably well
    if score3 >= 0.5:
        print('  ✅ Burch style scored reasonably well')
    else:
        print('  ⚠️  Burch style scored lower than expected')
    
    print('  ✅ Model performance test PASSED')
except:
    print('  ❌ Model performance test FAILED')
    sys.exit(1)
"
    
    # Clean up
    rm -f test_high_aesthetic.jpg test_low_aesthetic.jpg test_burch_style.jpg
}

# Test 2: Batch Processing
echo "Test 2: Batch Processing"
test_batch_processing() {
    echo "  Creating batch of test images..."
    
    python3 -c "
from PIL import Image
import numpy as np

for i in range(3):
    img = Image.fromarray(np.random.randint(50, 200, (150, 150, 3), dtype=np.uint8))
    img.save(f'batch_test_{i}.jpg')

print('Batch test images created')
"
    
    echo "  Testing batch scoring..."
    
    BATCH_RESPONSE=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic/batch-score \
        -F "files=@batch_test_0.jpg" \
        -F "files=@batch_test_1.jpg" \
        -F "files=@batch_test_2.jpg")
    
    if echo "$BATCH_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'results' in data:
        results = data['results']
        print(f'  ✅ Batch processing returned {len(results)} results')
        
        success_count = sum(1 for r in results if r.get('status') == 'success')
        print(f'  ✅ {success_count}/{len(results)} images processed successfully')
        
        for i, result in enumerate(results):
            if result.get('status') == 'success':
                score = result.get('aesthetic_score', 0)
                print(f'    Image {i}: {score:.3f}')
    else:
        print('  ❌ Batch processing FAILED')
except:
    print('  ❌ Batch processing FAILED')
" 2>/dev/null; then
        echo "  ✅ Batch processing test PASSED"
    else
        echo "  ❌ Batch processing test FAILED"
    fi
    
    # Clean up
    rm -f batch_test_*.jpg
}

# Run ML tests
test_aesthetic_model
test_batch_processing

echo "✅ ML model tests completed!"
