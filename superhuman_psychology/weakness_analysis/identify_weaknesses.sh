#!/bin/bash

echo "🔍 IDENTIFYING CHRIS BURCH'S PSYCHOLOGICAL WEAKNESSES"

map_blind_spots() {
    echo "👁️‍🗨️ Mapping psychological blind spots..."
    
    BLIND_SPOT_PROMPTS=(
        "What are Chris Burch's biggest blind spots - areas where his judgment is consistently poor or biased?"
        "What types of people or situations does Chris Burch consistently misjudge?"
        "Where does Chris Burch's overconfidence lead him astray?"
        "What patterns in his own behavior is Chris Burch blind to?"
        "What market signals or trends does Chris Burch consistently miss or misinterpret?"
    )
    
    for prompt in "${BLIND_SPOT_PROMPTS[@]}"; do
        ../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_blind_spot.sh "blind_spot_analysis" &
        ../../chris_research_engine/query_claude.sh "$prompt" | ./store_blind_spot.sh "blind_spot_analysis" &
        ../../chris_research_engine/query_grok.sh "$prompt" | ./store_blind_spot.sh "blind_spot_analysis" &
    done
}

identify_emotional_vulnerabilities() {
    echo "💔 Identifying emotional vulnerabilities..."
    
    VULNERABILITY_PROMPTS=(
        "What are Chris Burch's deepest emotional vulnerabilities that could affect his business judgment?"
        "What emotional triggers cause Chris Burch to make poor decisions?"
        "How can Chris Burch's ego be leveraged or manipulated?"
        "What fears does Chris Burch have that he tries to hide but that influence his decisions?"
        "What emotional needs does Chris Burch have that make him predictable?"
    )
    
    for prompt in "${VULNERABILITY_PROMPTS[@]}"; do
        ../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_vulnerability.sh "emotional_vulnerability" &
        ../../chris_research_engine/query_claude.sh "$prompt" | ./store_vulnerability.sh "emotional_vulnerability" &
        ../../chris_research_engine/query_grok.sh "$prompt" | ./store_vulnerability.sh "emotional_vulnerability" &
    done
}

# Execute weakness analysis
map_blind_spots &
identify_emotional_vulnerabilities &

wait
echo "✅ Psychological weakness analysis complete"
