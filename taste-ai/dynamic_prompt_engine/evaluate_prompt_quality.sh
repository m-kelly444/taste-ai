#!/bin/bash

# Use LLMs to evaluate which prompts produce the best insights

evaluate_prompt_effectiveness() {
    echo "📊 Evaluating prompt quality..."
    
    # Get recent responses
    RECENT_RESPONSES=$(redis-cli -p 6381 -n $LLM_QUERIES_DB KEYS "response:*" | tail -100)
    
    for response_key in $RECENT_RESPONSES; do
        RESPONSE_DATA=$(redis-cli -p 6381 -n $LLM_QUERIES_DB GET "$response_key")
        
        if [ ! -z "$RESPONSE_DATA" ]; then
            PROMPT=$(echo "$RESPONSE_DATA" | jq -r '.prompt // ""')
            RESPONSE=$(echo "$RESPONSE_DATA" | jq -r '.response // ""')
            
            if [ ! -z "$PROMPT" ] && [ ! -z "$RESPONSE" ]; then
                # Use LLMs to evaluate the quality of this prompt-response pair
                EVALUATION_REQUEST="Evaluate the quality of this prompt and response about Chris Burch analysis. Prompt: '$PROMPT' Response: '$RESPONSE'. Rate the insight quality (1-10), uniqueness (1-10), and actionability (1-10). Return as JSON with scores and reasoning."
                
                ./query_chatgpt.sh "$EVALUATION_REQUEST" | ./store_prompt_evaluation.sh "$response_key" "chatgpt" &
            fi
        fi
    done
}

evaluate_prompt_effectiveness
