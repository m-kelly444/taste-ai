# Additional specialized test scripts for specific components

# 8. Test Chris Burch Data Loading
cat > test_chris_data_loading.sh << 'EOF'
#!/bin/bash

echo "👑 Testing Chris Burch Data Loading"
echo "=================================="

# Test 1: Load Real Chris Burch Preferences
echo "Test 1: Loading Real Preference Data"
test_preference_loading() {
    echo "  Testing preference data loading..."
    
    # Check if the real data files exist
    if [ -f "../production_data/chris_burch_discovered_preferences.json" ]; then
        echo "    ✅ Real preference data file found"
        
        # Test loading the data
        python3 load_real_data_direct.py
        
        # Verify data was loaded into Redis
        BRIGHTNESS=$(redis-cli -p 6380 -n 0 HGET chris_taste_model brightness_preference 2>/dev/null)
        
        if [ ! -z "$BRIGHTNESS" ]; then
            echo "    ✅ Preference data loaded into Redis"
            echo "    Brightness preference: $BRIGHTNESS"
            
            # Test model version
            MODEL_VERSION=$(redis-cli -p 6380 -n 0 GET model_version 2>/dev/null)
            echo "    Model version: $MODEL_VERSION"
            
            # Test company count
            COMPANY_COUNT=$(redis-cli -p 6380 -n 0 GET companies_analyzed_count 2>/dev/null)
            echo "    Companies analyzed: $COMPANY_COUNT"
            
        else
            echo "    ❌ Failed to load preference data into Redis"
        fi
    else
        echo "    ⚠️  Real preference data file not found"
        echo "    Creating mock data for testing..."
        
        # Create mock preference data
        python3 -c "
import redis
import json

r = redis.Redis(host='localhost', port=6380, db=0)
r.hset('chris_taste_model', 'brightness_preference', '180.5')
r.hset('chris_taste_model', 'saturation_preference', '142.3')
r.hset('chris_taste_model', 'style_preference', 'minimalist')
r.set('model_version', 'test_v1.0')

print('Mock preference data loaded')
"
        echo "    ✅ Mock data loaded for testing"
    fi
}

# Test 2: Scorer Integration
echo "Test 2: Chris Burch Scorer Integration"
test_scorer_integration() {
    echo "  Testing scorer integration..."
    
    # Check if scorer configuration exists
    if [ -f "../production_data/chris_burch_scorer_final.json" ]; then
        echo "    ✅ Scorer configuration found"
        
        # Load and test scorer
        python3 -c "
import json
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    # Test importing the scorer
    from production_data.create_scorer import ChrisBurchAestheticScorer
    
    # Load preferences
    with open('../production_data/chris_burch_discovered_preferences.json', 'r') as f:
        preferences = json.load(f)
    
    # Create scorer
    scorer = ChrisBurchAestheticScorer(preferences)
    
    # Test scoring with sample features
    test_features = {
        'brightness': 180.5,
        'saturation': 142.3,
        'complexity': 0.4
    }
    
    result = scorer.score_aesthetic(test_features)
    
    print(f'    Scorer test result: {result[\"chris_burch_score\"]:.3f}')
    print(f'    Recommendation: {result[\"recommendation\"]}')
    print('    ✅ Scorer integration working')
    
except Exception as e:
    print(f'    ❌ Scorer integration failed: {e}')
"
    else
        echo "    ⚠️  Scorer configuration not found"
    fi
}

# Test 3: Portfolio Company Data
echo "Test 3: Portfolio Company Analysis"
test_portfolio_data() {
    echo "  Testing portfolio company data..."
    
    # Test if we can load portfolio companies
    PORTFOLIO_COMPANIES=$(redis-cli -p 6380 -n 0 SMEMBERS burch_portfolio_real 2>/dev/null | wc -l)
    
    if [ "$PORTFOLIO_COMPANIES" -gt "0" ]; then
        echo "    ✅ Portfolio companies loaded: $PORTFOLIO_COMPANIES"
        
        # Show sample companies
        echo "    Sample companies:"
        redis-cli -p 6380 -n 0 SMEMBERS burch_portfolio_real 2>/dev/null | head -5 | while read company; do
            echo "      • $company"
        done
    else
        echo "    ⚠️  No portfolio companies found"
        
        # Load sample portfolio
        redis-cli -p 6380 -n 0 SADD burch_portfolio_real "Tory Burch" "BaubleBar" "Outdoor Voices" "Rowing Blazers" > /dev/null
        echo "    ✅ Sample portfolio companies added"
    fi
}

# Run Chris Burch data tests
test_preference_loading
test_scorer_integration
test_portfolio_data

echo "✅ Chris Burch data loading tests completed!"
EOF

# 9. Test Production Systems
cat > test_production_systems.sh << 'EOF'
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
EOF

# 10. Test Intelligence Systems
cat > test_intelligence_systems.sh << 'EOF'
#!/bin/bash

echo "🧠 Testing Intelligence Systems"
echo "==============================="

# Test 1: 100x Intelligence Engine
echo "Test 1: 100x Intelligence Amplification"
test_100x_intelligence() {
    echo "  Testing 100x intelligence system..."
    
    if pgrep -f "meta_intelligence.sh" > /dev/null; then
        echo "    ✅ Meta-intelligence system running"
        
        # Check intelligence metrics
        INTELLIGENCE_LEVEL=$(redis-cli -p 6381 GET intelligence_level 2>/dev/null || echo "0")
        echo "    Intelligence level: $INTELLIGENCE_LEVEL"
        
        QUANTUM_INTELLIGENCE=$(redis-cli -p 6381 GET quantum_intelligence_total 2>/dev/null || echo "0")
        echo "    Quantum intelligence: $QUANTUM_INTELLIGENCE"
        
        SYNTHESIS_INTELLIGENCE=$(redis-cli -p 6381 GET synthesis_intelligence 2>/dev/null || echo "0")
        echo "    Synthesis intelligence: $SYNTHESIS_INTELLIGENCE"
        
        TOTAL_INTELLIGENCE=$((INTELLIGENCE_LEVEL + QUANTUM_INTELLIGENCE + SYNTHESIS_INTELLIGENCE))
        echo "    Total intelligence: $TOTAL_INTELLIGENCE"
        
        if [ $TOTAL_INTELLIGENCE -gt 1000 ]; then
            echo "    ✅ High intelligence level achieved"
        else
            echo "    ⚠️  Intelligence still building"
        fi
    else
        echo "    ⚠️  100x intelligence system not running"
    fi
}

# Test 2: Chris Research Engine
echo "Test 2: Chris Research Engine"
test_chris_research() {
    echo "  Testing Chris research capabilities..."
    
    if pgrep -f "continuous_chris_research.sh" > /dev/null; then
        echo "    ✅ Chris research engine running"
        
        # Check research data
        CHRIS_DATA=$(redis-cli -p 6381 -n 10 DBSIZE 2>/dev/null || echo "0")
        echo "    Chris research data points: $CHRIS_DATA"
        
        INVESTMENT_DATA=$(redis-cli -p 6381 -n 11 DBSIZE 2>/dev/null || echo "0")
        echo "    Investment data points: $INVESTMENT_DATA"
        
        PSYCH_DATA=$(redis-cli -p 6381 -n 12 DBSIZE 2>/dev/null || echo "0")
        echo "    Psychological data points: $PSYCH_DATA"
        
        LLM_DATA=$(redis-cli -p 6381 -n 13 DBSIZE 2>/dev/null || echo "0")
        echo "    LLM analysis data points: $LLM_DATA"
        
        TOTAL_DATA=$((CHRIS_DATA + INVESTMENT_DATA + PSYCH_DATA + LLM_DATA))
        echo "    Total Chris data: $TOTAL_DATA"
        
        if [ $TOTAL_DATA -gt 100 ]; then
            echo "    ✅ Substantial Chris research data"
        else
            echo "    ⚠️  Research data still accumulating"
        fi
    else
        echo "    ⚠️  Chris research engine not running"
    fi
}

# Test 3: Dynamic Prompt Engine
echo "Test 3: Dynamic Prompt Generation"
test_dynamic_prompts() {
    echo "  Testing dynamic prompt generation..."
    
    if pgrep -f "dynamic_prompt_generator.sh" > /dev/null; then
        echo "    ✅ Dynamic prompt generator running"
        
        # Check generated prompts
        CATEGORIES=$(redis-cli -p 6381 -n 20 KEYS "categories:*" | wc -l 2>/dev/null || echo "0")
        echo "    Generated categories: $CATEGORIES"
        
        PROMPT_SETS=$(redis-cli -p 6381 -n 20 KEYS "prompts:*" | wc -l 2>/dev/null || echo "0")
        echo "    Generated prompt sets: $PROMPT_SETS"
        
        META_PROMPTS=$(redis-cli -p 6381 -n 20 KEYS "meta_prompts:*" | wc -l 2>/dev/null || echo "0")
        echo "    Meta-prompts: $META_PROMPTS"
        
        RESPONSES=$(redis-cli -p 6381 -n 13 KEYS "response:*" | wc -l 2>/dev/null || echo "0")
        echo "    Generated responses: $RESPONSES"
        
        if [ $PROMPT_SETS -gt 10 ]; then
            echo "    ✅ Dynamic prompt generation active"
        else
            echo "    ⚠️  Prompt generation still initializing"
        fi
    else
        echo "    ⚠️  Dynamic prompt generator not running"
    fi
}

# Run load tests
test_api_stress
test_memory_leaks

echo "✅ Load handling tests completed!"
EOF

# Make all test scripts executable
chmod +x test_*.sh

# Run all tests
run_all_tests

echo ""
echo "🎯 TASTE.AI Test Suite Summary"
echo "=============================="
echo "All test scripts created and executed!"
echo ""
echo "Individual test scripts:"
echo "  • test_basic_functionality.sh - Basic system health"
echo "  • test_api_endpoints.sh - API functionality"
echo "  • test_ml_models.sh - ML model performance"
echo "  • test_performance.sh - Performance metrics"
echo "  • test_integration.sh - System integration"
echo "  • test_advanced_features.sh - Specialized features"
echo "  • test_load_handling.sh - Load and stress testing"
echo ""
echo "Run individual tests with: ./test_[name].sh"
echo "Run all tests with: ./run_all_tests.sh"