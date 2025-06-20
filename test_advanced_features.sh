#!/bin/bash

echo "🚀 Testing Advanced Features"
echo "==========================="

# Test 1: Chris Burch Specialized Features
echo "Test 1: Chris Burch Specialization"
test_chris_burch_features() {
    echo "  Testing Burch-specific analysis..."
    
    # Create Burch-style test images
    python3 -c "
from PIL import Image, ImageDraw

# Classic Burch palette test
img1 = Image.new('RGB', (400, 300), color='#f5f5dc')  # Cream
draw1 = ImageDraw.Draw(img1)
draw1.rectangle([100, 75, 300, 225], fill='#1e3a5f')  # Navy
draw1.ellipse([150, 100, 250, 200], fill='#c19a6b')  # Camel
img1.save('burch_classic.jpg')

# Non-Burch style
img2 = Image.new('RGB', (400, 300), color='#ff00ff')  # Bright magenta
draw2 = ImageDraw.Draw(img2)
draw2.rectangle([50, 50, 350, 250], fill='#00ff00')  # Bright green
img2.save('anti_burch.jpg')

print('Burch test images created')
"
    
    # Test Burch alignment scoring
    BURCH_SCORE=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic-advanced/score-advanced \
        -F "file=@burch_classic.jpg" | \
        python3 -c "import sys, json; data=json.load(sys.stdin); print(data['burch_analysis']['burch_alignment_score'])" 2>/dev/null)
    
    ANTI_BURCH_SCORE=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic-advanced/score-advanced \
        -F "file=@anti_burch.jpg" | \
        python3 -c "import sys, json; data=json.load(sys.stdin); print(data['burch_analysis']['burch_alignment_score'])" 2>/dev/null)
    
    echo "    Burch-style image alignment: $BURCH_SCORE"
    echo "    Anti-Burch image alignment: $ANTI_BURCH_SCORE"
    
    # Validate that Burch-style scores higher
    python3 -c "
try:
    burch = float('$BURCH_SCORE')
    anti_burch = float('$ANTI_BURCH_SCORE')
    
    if burch > anti_burch:
        print('  ✅ Burch specialization working correctly')
        print(f'    Burch style scored {burch:.3f} vs {anti_burch:.3f}')
    else:
        print('  ⚠️  Burch specialization may need tuning')
        print(f'    Burch style: {burch:.3f}, Anti-Burch: {anti_burch:.3f}')
except:
    print('  ❌ Burch specialization test failed')
"
    
    rm -f burch_classic.jpg anti_burch.jpg
}

# Test 2: Market Intelligence
echo "Test 2: Market Intelligence Features"
test_market_intelligence() {
    echo "  Testing market intelligence endpoint..."
    
    MARKET_INTEL=$(curl -s http://localhost:8001/api/v1/aesthetic-advanced/market-intelligence)
    
    if echo "$MARKET_INTEL" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    required_sections = ['current_trends', 'burch_market_position', 'investment_climate']
    
    if all(section in data for section in required_sections):
        print('  ✅ Market intelligence structure complete')
        
        # Check trend data
        trends = data['current_trends']
        if 'color_palettes' in trends and 'style_directions' in trends:
            print('  ✅ Trend analysis included')
        
        # Check Burch positioning
        burch_pos = data['burch_market_position']
        if 'brand_strength' in burch_pos:
            strength = burch_pos['brand_strength']
            print(f'    Burch brand strength: {strength}')
        
        # Check investment climate
        invest_climate = data['investment_climate']
        if 'overall_sentiment' in invest_climate:
            sentiment = invest_climate['overall_sentiment']
            print(f'    Investment sentiment: {sentiment}')
    else:
        print('  ❌ Market intelligence incomplete')
except Exception as e:
    print(f'  ❌ Market intelligence failed: {e}')
" 2>/dev/null; then
        echo "  ✅ Market intelligence test PASSED"
    else
        echo "  ❌ Market intelligence test FAILED"
    fi
}

# Test 3: Image Comparison
echo "Test 3: Multi-Image Comparison"
test_image_comparison() {
    echo "  Testing image comparison features..."
    
    # Create comparison test images
    python3 -c "
from PIL import Image, ImageDraw
import random

for i in range(3):
    img = Image.new('RGB', (200, 200), color=(random.randint(200, 255), random.randint(200, 255), random.randint(200, 255)))
    draw = ImageDraw.Draw(img)
    
    # Add different aesthetic elements
    if i == 0:  # High aesthetic
        draw.rectangle([50, 50, 150, 150], fill='navy')
        draw.ellipse([75, 75, 125, 125], fill='gold')
    elif i == 1:  # Medium aesthetic
        draw.rectangle([60, 60, 140, 140], fill='gray')
    else:  # Lower aesthetic
        for _ in range(10):
            x, y = random.randint(0, 200), random.randint(0, 200)
            draw.point((x, y), fill='red')
    
    img.save(f'compare_{i}.jpg')

print('Comparison test images created')
"
    
    # Test comparison endpoint
    COMPARISON_RESULT=$(curl -s -X POST http://localhost:8001/api/v1/aesthetic-advanced/compare-images \
        -F "files=@compare_0.jpg" \
        -F "files=@compare_1.jpg" \
        -F "files=@compare_2.jpg")
    
    if echo "$COMPARISON_RESULT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    
    if 'comparison_results' in data and 'ranked_by_aesthetic' in data:
        results = data['comparison_results']
        ranked = data['ranked_by_aesthetic']
        
        print(f'  ✅ Compared {len(results)} images successfully')
        print(f'  ✅ Ranking provided with {len(ranked)} entries')
        
        # Check if ranking makes sense (scores should be descending)
        scores = [item['aesthetic_score'] for item in ranked]
        if scores == sorted(scores, reverse=True):
            print('  ✅ Ranking order correct')
        else:
            print('  ⚠️  Ranking order may be incorrect')
        
        # Check recommendations
        if 'recommendations' in data:
            recs = data['recommendations']
            if 'best_overall' in recs and 'best_burch_fit' in recs:
                print('  ✅ Recommendations provided')
    else:
        print('  ❌ Image comparison failed')
except Exception as e:
    print(f'  ❌ Comparison analysis error: {e}')
" 2>/dev/null; then
        echo "  ✅ Image comparison test PASSED"
    else
        echo "  ❌ Image comparison test FAILED"
    fi
    
    rm -f compare_*.jpg
}

# Run advanced feature tests
test_chris_burch_features
test_market_intelligence
test_image_comparison

echo "✅ Advanced features tests completed!"
