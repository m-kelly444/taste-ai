#!/bin/bash

# Deep Psychological Analysis of Chris Burch

run_psychoanalysis() {
    echo "🧠 Running Chris Burch Psychoanalysis..."
    
    # Gather all available data about Chris
    ALL_CHRIS_DATA=$(redis-cli -p 6381 -n $CHRIS_BURCH_DB KEYS "*" | xargs -I {} redis-cli -p 6381 -n $CHRIS_BURCH_DB GET {})
    
    # Personality frameworks to apply
    PERSONALITY_FRAMEWORKS=(
        "big_five_personality"
        "myers_briggs"
        "enneagram"
        "disc_assessment"
        "emotional_intelligence"
        "leadership_styles"
        "decision_making_styles"
        "risk_assessment_psychology"
        "cognitive_biases"
        "motivational_drivers"
    )
    
    for framework in "${PERSONALITY_FRAMEWORKS[@]}"; do
        echo "🔍 Analyzing Chris through $framework..."
        
        # Create analysis prompt
        ANALYSIS_PROMPT="Based on all available information about Chris Burch, analyze his personality using the $framework framework. Provide specific examples from his business decisions, public statements, and career trajectory."
        
        # Run analysis through multiple LLMs
        ./analyze_with_framework.sh "$framework" "$ANALYSIS_PROMPT" &
    done
    
    # Specific psychological analyses
    ./analyze_chris_decision_patterns.sh &
    ./analyze_chris_risk_psychology.sh &
    ./analyze_chris_social_dynamics.sh &
    ./analyze_chris_emotional_patterns.sh &
    ./analyze_chris_cognitive_style.sh &
    
    # Comparative analysis
    ./compare_chris_to_other_entrepreneurs.sh &
    ./analyze_chris_evolution_over_time.sh &
}

run_psychoanalysis
