#!/bin/bash

echo "💝 ANALYZING CHRIS BURCH'S EMOTIONAL PATTERNS"

map_emotional_triggers() {
    echo "⚡ Mapping emotional triggers..."
    
    # Analyze what emotionally drives Chris
    EMOTIONAL_TRIGGER_PROMPTS=(
        "What specific situations trigger strong emotional responses in Chris Burch?"
        "How does Chris Burch's emotional state affect his investment decisions?"
        "What are Chris Burch's deepest fears and how do they manifest in his behavior?"
        "What gives Chris Burch the strongest positive emotional reactions?"
        "How does Chris Burch handle emotional stress and pressure?"
        "What emotional patterns repeat in Chris Burch's relationships and business dealings?"
    )
    
    for prompt in "${EMOTIONAL_TRIGGER_PROMPTS[@]}"; do
        ../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_emotional_pattern.sh "trigger_analysis" &
        ../../chris_research_engine/query_claude.sh "$prompt" | ./store_emotional_pattern.sh "trigger_analysis" &
        ../../chris_research_engine/query_grok.sh "$prompt" | ./store_emotional_pattern.sh "trigger_analysis" &
    done
}

analyze_emotional_intelligence() {
    echo "🧠💖 Analyzing emotional intelligence..."
    
    EQ_ANALYSIS_PROMPT="Analyze Chris Burch's emotional intelligence across these dimensions: self-awareness, self-regulation, motivation, empathy, and social skills. For each dimension, provide specific examples from his behavior, rate his level (1-10), identify strengths and weaknesses, and explain how this affects his business success. Include analysis of how he reads others, manages his own emotions, and influences people emotionally."
    
    ../../chris_research_engine/query_chatgpt.sh "$EQ_ANALYSIS_PROMPT" | ./store_eq_analysis.sh "emotional_intelligence" &
    ../../chris_research_engine/query_claude.sh "$EQ_ANALYSIS_PROMPT" | ./store_eq_analysis.sh "emotional_intelligence" &
    ../../chris_research_engine/query_grok.sh "$EQ_ANALYSIS_PROMPT" | ./store_eq_analysis.sh "emotional_intelligence" &
}

# Execute emotional analysis
map_emotional_triggers &
analyze_emotional_intelligence &

wait
echo "✅ Emotional pattern analysis complete"
