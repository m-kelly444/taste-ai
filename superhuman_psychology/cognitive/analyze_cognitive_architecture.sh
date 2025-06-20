#!/bin/bash

echo "🧮 ANALYZING CHRIS BURCH'S COGNITIVE ARCHITECTURE"

analyze_thinking_patterns() {
    # Extract thinking patterns from every decision Chris has made
    echo "🔍 Extracting cognitive patterns from all available data..."
    
    # Get all Chris data
    ALL_CHRIS_DATA=$(find ../../ -name "*chris*" -type f | head -100)
    
    for data_file in $ALL_CHRIS_DATA; do
        if [ -f "$data_file" ]; then
            # Analyze decision-making patterns
            DECISIONS=$(grep -i "decision\|choose\|select\|invest\|buy\|sell" "$data_file" 2>/dev/null)
            
            echo "$DECISIONS" | while read decision; do
                if [ ! -z "$decision" ]; then
                    # Send to LLMs for cognitive pattern analysis
                    COGNITIVE_ANALYSIS_PROMPT="Analyze this Chris Burch decision for cognitive patterns: '$decision'. Identify: reasoning style, risk assessment approach, information processing method, decision framework used, cognitive biases present, and mental models applied. Return detailed psychological analysis."
                    
                    # Query all LLMs
                    ../../chris_research_engine/query_chatgpt.sh "$COGNITIVE_ANALYSIS_PROMPT" | ./store_cognitive_pattern.sh "decision_analysis" &
                    ../../chris_research_engine/query_claude.sh "$COGNITIVE_ANALYSIS_PROMPT" | ./store_cognitive_pattern.sh "decision_analysis" &
                    ../../chris_research_engine/query_grok.sh "$COGNITIVE_ANALYSIS_PROMPT" | ./store_cognitive_pattern.sh "decision_analysis" &
                fi
            done
        fi
    done
}

map_mental_models() {
    echo "🗺️ Mapping Chris Burch's mental models..."
    
    # Generate prompts to understand his mental frameworks
    MENTAL_MODEL_PROMPTS=(
        "How does Chris Burch conceptualize risk vs reward in fashion investments?"
        "What mental framework does Chris Burch use to evaluate brand potential?"
        "How does Chris Burch's mind process market timing decisions?"
        "What cognitive shortcuts does Chris Burch use in aesthetic judgments?"
        "How does Chris Burch mentally categorize and evaluate people?"
        "What decision trees exist in Chris Burch's mind for investment choices?"
    )
    
    for prompt in "${MENTAL_MODEL_PROMPTS[@]}"; do
        ../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_mental_model.sh "framework_analysis" &
        ../../chris_research_engine/query_claude.sh "$prompt" | ./store_mental_model.sh "framework_analysis" &
        ../../chris_research_engine/query_grok.sh "$prompt" | ./store_mental_model.sh "framework_analysis" &
    done
}

analyze_cognitive_biases() {
    echo "🎭 Analyzing Chris Burch's cognitive biases..."
    
    # Identify specific biases in his thinking
    BIAS_ANALYSIS_PROMPT="Based on all available information about Chris Burch's decisions and statements, identify his specific cognitive biases. For each bias, provide: examples from his behavior, how it affects his decisions, when it's strongest, and how it could be leveraged or mitigated. Focus on confirmation bias, anchoring bias, availability heuristic, loss aversion, overconfidence bias, and any unique biases specific to him."
    
    ../../chris_research_engine/query_chatgpt.sh "$BIAS_ANALYSIS_PROMPT" | ./store_cognitive_bias.sh "bias_analysis" &
    ../../chris_research_engine/query_claude.sh "$BIAS_ANALYSIS_PROMPT" | ./store_cognitive_bias.sh "bias_analysis" &
    ../../chris_research_engine/query_grok.sh "$BIAS_ANALYSIS_PROMPT" | ./store_cognitive_bias.sh "bias_analysis" &
}

# Execute cognitive analysis
analyze_thinking_patterns &
map_mental_models &
analyze_cognitive_biases &

wait
echo "✅ Cognitive architecture analysis complete"
