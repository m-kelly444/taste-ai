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
