#!/bin/bash

echo "🔧 REVERSE ENGINEERING CHRIS BURCH'S DECISION PROCESS"

map_decision_algorithms() {
    echo "🗺️ Mapping decision algorithms..."
    
    DECISION_MAPPING_PROMPTS=(
        "Reverse engineer Chris Burch's exact decision-making algorithm for investment choices. What factors does he weigh, in what order, with what weightings?"
        "Map Chris Burch's decision tree for aesthetic judgments - how does he mentally process visual appeal?"
        "What is Chris Burch's exact formula for timing market entries and exits?"
        "Reverse engineer how Chris Burch evaluates people - what criteria does he use and in what sequence?"
        "Map Chris Burch's risk assessment algorithm - how does he calculate and weigh different types of risk?"
    )
    
    for prompt in "${DECISION_MAPPING_PROMPTS[@]}"; do
        ../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_decision_algorithm.sh "algorithm_mapping" &
        ../../chris_research_engine/query_claude.sh "$prompt" | ./store_decision_algorithm.sh "algorithm_mapping" &
        ../../chris_research_engine/query_grok.sh "$prompt" | ./store_decision_algorithm.sh "algorithm_mapping" &
    done
}

create_influence_maps() {
    echo "🎯 Creating influence maps..."
    
    INFLUENCE_MAPPING_PROMPTS=(
        "Map every factor that influences Chris Burch's decisions: people, information sources, emotional states, market conditions, personal experiences, etc."
        "What are the hidden influencers in Chris Burch's decision-making that he might not even be conscious of?"
        "How do different people in Chris Burch's network influence his thinking and decisions?"
        "What external factors (news, market events, social trends) have the strongest influence on Chris Burch's judgment?"
        "Map Chris Burch's information hierarchy - what sources does he trust most and why?"
    )
    
    for prompt in "${INFLUENCE_MAPPING_PROMPTS[@]}"; do
        ../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_influence_map.sh "influence_analysis" &
        ../../chris_research_engine/query_claude.sh "$prompt" | ./store_influence_map.sh "influence_analysis" &
        ../../chris_research_engine/query_grok.sh "$prompt" | ./store_influence_map.sh "influence_analysis" &
    done
}

# Execute decision engineering
map_decision_algorithms &
create_influence_maps &

wait
echo "✅ Decision-making reverse engineering complete"
