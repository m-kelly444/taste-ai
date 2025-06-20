#!/bin/bash

echo "😶 ANALYZING CHRIS BURCH MICRO-EXPRESSIONS"

analyze_facial_patterns() {
    echo "👁️ Analyzing facial expression patterns..."
    
    # Generate analysis of Chris's micro-expressions from available media
    MICRO_EXPRESSION_PROMPTS=(
        "Analyze Chris Burch's facial micro-expressions during investment pitches. What does his face reveal about his interest level, skepticism, excitement, or decision-making process?"
        "What are Chris Burch's 'tells' - unconscious facial expressions that reveal his true thoughts during negotiations?"
        "How does Chris Burch's facial expression change when he's genuinely interested vs. being polite?"
        "What micro-expressions does Chris Burch show when he's evaluating aesthetic appeal?"
        "Analyze Chris Burch's eye movement patterns and what they reveal about his thinking process"
    )
    
    for prompt in "${MICRO_EXPRESSION_PROMPTS[@]}"; do
        ../../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_micro_expression.sh "facial_analysis" &
        ../../../chris_research_engine/query_claude.sh "$prompt" | ./store_micro_expression.sh "facial_analysis" &
        ../../../chris_research_engine/query_grok.sh "$prompt" | ./store_micro_expression.sh "facial_analysis" &
    done
}

# Execute micro-expression analysis
analyze_facial_patterns

wait
echo "✅ Micro-expression analysis complete"
