#!/bin/bash

echo "🏭 Testing Production Systems"
echo "============================"

# Test 1: Keyword Engine
echo "Test 1: Keyword Discovery Engine"
test_keyword_engine() {
    echo "  Testing keyword engine functionality..."
    
    # Check if keyword engine is running
    if pgrep -f "live_keyword_engine.py" > /dev/null; then
        echo "    ✅ Keyword engine process running"
        
        # Check Redis for discovered keywords
        KEYWORD_COUNT=$(redis-cli -p 6381 -n 1 SCARD all_keywords 2>/dev/null || echo "0")
        echo "    Keywords discovered: $KEYWORD_COUNT"
        
        # Check active keywords
        ACTIVE_COUNT=$(redis-cli -p 6381 -n 1 SCARD active_keywords 2>/dev/null || echo "0")
        echo "    Active keywords: $ACTIVE_COUNT"
        
        if [ "$KEYWORD_COUNT" -gt "0" ]; then
            echo "    ✅ Keyword discovery working"
            
            # Show sample keywords
            echo "    Sample keywords:"
            redis-cli -p 6381 -n 1 SMEMBERS active_keywords 2>/dev/null | head -3 | while read keyword; do
                echo "      • $keyword"
            done
        else
            echo "    ⚠️  No keywords discovered yet"
        fi
    else
        echo "    ⚠️  Keyword engine not running"
        echo "    Starting keyword engine test..."
        
        # Start keyword engine temporarily for testing
        cd production/keyword_engine/discovery
        timeout 30 python3 live_keyword_engine.py &
        KEYWORD_PID=$!
        
        sleep 10
        
        # Check if it generated any test data
        TEST_KEYWORD_COUNT=$(redis-cli -p 6381 -n 1 SCARD all_keywords 2>/dev/null || echo "0")
        
        if [ "$TEST_KEYWORD_COUNT" -gt "0" ]; then
            echo "    ✅ Keyword engine test successful"
        else
            echo "    ❌ Keyword engine test failed"
        fi
        
        kill $KEYWORD_PID 2>/dev/null
        cd ../../..
    fi
}

# Test 2: Adaptive Models
echo "Test 2: Adaptive Model Engine"
test_adaptive_models() {
    echo "  Testing adaptive model functionality..."
    
    if pgrep -f "adaptive_model_engine.py" > /dev/null; then
        echo "    ✅ Adaptive model engine running"
        
        # Check for model evolution data
        MODEL_REPORT=$(redis-cli -p 6381 -n 4 GET model_performance_report 2>/dev/null)
        
        if [ ! -z "$MODEL_REPORT" ]; then
            echo "    ✅ Model performance reports available"
            
            # Parse report data
            echo "$MODEL_REPORT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'    Generation: {data.get(\"generation\", 0)}')
    print(f'    Population: {data.get(\"population_size\", 0)} models')
    
    models = data.get('models', {})
    if models:
        best_model = max(models.items(), key=lambda x: x[1].get('recent_fitness', 0))
        print(f'    Best model: {best_model[0][:20]}...')
        print(f'    Best fitness: {best_model[1].get(\"recent_fitness\", 0):.4f}')
except:
    print('    Could not parse model report')
"
        else
            echo "    ⚠️  No model performance reports yet"
        fi
    else
        echo "    ⚠️  Adaptive model engine not running"
    fi
}

# Test 3: Real-time Processing
echo "Test 3: Real-time Processing Engine"
test_realtime_processing() {
    echo "  Testing real-time processing..."
    
    if pgrep -f "realtime_processor.py" > /dev/null; then
        echo "    ✅ Real-time processor running"
        
        # Check intelligence growth
        INTELLIGENCE=$(redis-cli -p 6381 -n 3 GET previous_intelligence 2>/dev/null || echo "0.0000")
        echo "    Current intelligence level: $INTELLIGENCE"
        
        # Check pattern discovery
        PATTERN_COUNT=$(redis-cli -p 6381 -n 3 KEYS "validated_pattern:*" | wc -l 2>/dev/null || echo "0")
        echo "    Discovered patterns: $PATTERN_COUNT"
        
        # Check correlations
        CORRELATION_COUNT=$(redis-cli -p 6381 -n 3 KEYS "correlation:*" | wc -l 2>/dev/null || echo "0")
        echo "    Learned correlations: $CORRELATION_COUNT"
        
        if [ "$PATTERN_COUNT" -gt "0" ] || [ "$CORRELATION_COUNT" -gt "0" ]; then
            echo "    ✅ Real-time processing active"
        else
            echo "    ⚠️  No processing data yet"
        fi
    else
        echo "    ⚠️  Real-time processor not running"
    fi
}

# Test 4: Functional Discovery
echo "Test 4: Functional Discovery Engine"
test_functional_discovery() {
    echo "  Testing functional discovery..."
    
    if pgrep -f "functional_discovery.py" > /dev/null; then
        echo "    ✅ Functional discovery engine running"
        
        # Check discovered domains
        DOMAIN_COUNT=$(redis-cli -p 6381 -n 2 SCARD discovered_domains 2>/dev/null || echo "0")
        echo "    Discovered domains: $DOMAIN_COUNT"
        
        # Check discoveries
        DISCOVERY_COUNT=$(redis-cli -p 6381 -n 2 SCARD all_discoveries 2>/dev/null || echo "0")
        echo "    Total discoveries: $DISCOVERY_COUNT"
        
        if [ "$DISCOVERY_COUNT" -gt "0" ]; then
            echo "    ✅ Functional discovery active"
        else
            echo "    ⚠️  No discoveries yet"
        fi
    else
        echo "    ⚠️  Functional discovery engine not running"
    fi
}

# Run production system tests
test_keyword_engine
test_adaptive_models
test_realtime_processing
test_functional_discovery

echo "✅ Production systems tests completed!"
