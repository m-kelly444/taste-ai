#!/bin/bash

echo "🕳️ ANALYZING CHRIS BURCH'S SUBCONSCIOUS MIND"

uncover_hidden_motivations() {
    echo "🔍 Uncovering hidden motivations..."
    
    # Dig deep into subconscious drivers
    SUBCONSCIOUS_PROMPTS=(
        "What are Chris Burch's deepest, unspoken motivations that drive his behavior?"
        "What childhood experiences shaped Chris Burch's current psychological patterns?"
        "What does Chris Burch secretly fear most, and how does this manifest unconsciously?"
        "What are Chris Burch's hidden insecurities and how do they influence his decisions?"
        "What unconscious patterns does Chris Burch repeat in relationships and business?"
        "What does Chris Burch's ego structure look like and what feeds it?"
        "What are Chris Burch's blind spots about himself?"
    )
    
    for prompt in "${SUBCONSCIOUS_PROMPTS[@]}"; do
        ../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_subconscious_analysis.sh "hidden_motivations" &
        ../../chris_research_engine/query_claude.sh "$prompt" | ./store_subconscious_analysis.sh "hidden_motivations" &
        ../../chris_research_engine/query_grok.sh "$prompt" | ./store_subconscious_analysis.sh "hidden_motivations" &
    done
}

analyze_shadow_personality() {
    echo "🌑 Analyzing shadow personality..."
    
    SHADOW_ANALYSIS_PROMPT="Analyze Chris Burch's 'shadow' personality - the hidden, repressed, or denied aspects of his psyche. What traits does he reject in himself? What does he project onto others? How does his shadow manifest in his business dealings, relationships, and decision-making? What would he never admit about himself? How can understanding his shadow predict his behavior?"
    
    ../../chris_research_engine/query_chatgpt.sh "$SHADOW_ANALYSIS_PROMPT" | ./store_shadow_analysis.sh "shadow_personality" &
    ../../chris_research_engine/query_claude.sh "$SHADOW_ANALYSIS_PROMPT" | ./store_shadow_analysis.sh "shadow_personality" &
    ../../chris_research_engine/query_grok.sh "$SHADOW_ANALYSIS_PROMPT" | ./store_shadow_analysis.sh "shadow_personality" &
}

# Execute subconscious analysis
uncover_hidden_motivations &
analyze_shadow_personality &

wait
echo "✅ Subconscious analysis complete"
