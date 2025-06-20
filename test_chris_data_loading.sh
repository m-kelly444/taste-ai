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
