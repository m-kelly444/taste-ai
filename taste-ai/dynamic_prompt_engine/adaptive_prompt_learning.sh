#!/bin/bash

# Learn from successful prompts to generate better ones

learn_from_best_prompts() {
    echo "🧠 Learning from most successful prompts..."
    
    # Get prompt evaluations
    EVALUATIONS=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB KEYS "evaluation:*" | head -50)
    
    # Find highest-rated prompts
    BEST_PROMPTS=""
    for eval_key in $EVALUATIONS; do
        EVAL_DATA=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB GET "$eval_key")
        
        if [ ! -z "$EVAL_DATA" ]; then
            # Extract high-scoring prompts (this would need proper JSON parsing in real implementation)
            SCORE=$(echo "$EVAL_DATA" | jq -r '.total_score // 0' 2>/dev/null || echo "0")
            
            if [ $(echo "$SCORE > 8" | bc 2>/dev/null || echo "0") -eq 1 ]; then
                PROMPT=$(echo "$EVAL_DATA" | jq -r '.original_prompt // ""')
                BEST_PROMPTS="$BEST_PROMPTS\n$PROMPT"
            fi
        fi
    done
    
    if [ ! -z "$BEST_PROMPTS" ]; then
        # Use best prompts to generate even better ones
        LEARNING_REQUEST="Analyze these highly successful Chris Burch analysis prompts: $BEST_PROMPTS. Identify what makes them effective, then generate 40 new prompts that incorporate these successful patterns but explore new aspects. Return as JSON array."
        
        ./query_chatgpt.sh "$LEARNING_REQUEST" | ./store_learned_prompts.sh "chatgpt" &
        ./query_claude.sh "$LEARNING_REQUEST" | ./store_learned_prompts.sh "claude" &
        ./query_grok.sh "$LEARNING_REQUEST" | ./store_learned_prompts.sh "grok" &
    fi
}

learn_from_best_prompts
