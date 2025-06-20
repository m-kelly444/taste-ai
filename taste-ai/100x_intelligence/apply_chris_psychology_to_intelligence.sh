#!/bin/bash

PSYCH_INSIGHT="$1"

# Apply Chris's psychological profile to enhance all intelligence systems

apply_to_keyword_engine() {
    # Extract personality traits that affect keyword preferences
    PERSONALITY_TRAITS=$(echo "$PSYCH_INSIGHT" | jq -r '.personality_traits // []' 2>/dev/null || echo "[]")
    
    if [ "$PERSONALITY_TRAITS" != "[]" ]; then
        # Bias keyword discovery based on Chris's personality
        redis-cli -p 6381 -n 1 SET "chris_personality_bias" "$PERSONALITY_TRAITS"
    fi
}

apply_to_discovery_engine() {
    # Extract decision-making patterns
    DECISION_PATTERNS=$(echo "$PSYCH_INSIGHT" | jq -r '.decision_patterns // []' 2>/dev/null || echo "[]")
    
    if [ "$DECISION_PATTERNS" != "[]" ]; then
        # Guide discovery based on how Chris makes decisions
        redis-cli -p 6381 -n 2 SET "chris_decision_guidance" "$DECISION_PATTERNS"
    fi
}

apply_to_adaptive_models() {
    # Extract learning preferences
    LEARNING_STYLE=$(echo "$PSYCH_INSIGHT" | jq -r '.learning_style // {}' 2>/dev/null || echo "{}")
    
    if [ "$LEARNING_STYLE" != "{}" ]; then
        # Adapt model learning to match Chris's cognitive style
        redis-cli -p 6381 -n 4 SET "chris_learning_adaptation" "$LEARNING_STYLE"
    fi
}

apply_to_quantum_processing() {
    # Extract risk tolerance and uncertainty handling
    RISK_PROFILE=$(echo "$PSYCH_INSIGHT" | jq -r '.risk_profile // {}' 2>/dev/null || echo "{}")
    
    if [ "$RISK_PROFILE" != "{}" ]; then
        # Adjust quantum superposition based on Chris's risk tolerance
        redis-cli -p 6381 -n 8 SET "chris_risk_adaptation" "$RISK_PROFILE"
    fi
}

# Apply psychology to all systems
apply_to_keyword_engine &
apply_to_discovery_engine &
apply_to_adaptive_models &
apply_to_quantum_processing &

wait
