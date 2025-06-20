#!/bin/bash

# Evolve existing prompts to create better ones

evolve_prompts() {
    echo "🧬 Evolving existing prompts..."
    
    # Get existing prompts
    EXISTING_PROMPT_KEYS=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB KEYS "prompts:*" | shuf | head -20)
    
    for prompt_key in $EXISTING_PROMPT_KEYS; do
        PROMPT_DATA=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB GET "$prompt_key")
        
        if [ ! -z "$PROMPT_DATA" ]; then
            EXISTING_PROMPTS=$(echo "$PROMPT_DATA" | jq -r '.prompts // "[]"')
            CATEGORY=$(echo "$PROMPT_DATA" | jq -r '.category // "unknown"')
            
            # Evolve these prompts
            EVOLUTION_REQUEST="Take these existing prompts about Chris Burch: $EXISTING_PROMPTS. Create 30 evolved versions that are deeper, more sophisticated, more psychologically insightful, or approach the same topics from completely different angles. Return as JSON array."
            
            # Evolve with all LLMs
            ./query_chatgpt.sh "$EVOLUTION_REQUEST" | ./store_evolved_prompts.sh "$CATEGORY" "chatgpt" &
            ./query_claude.sh "$EVOLUTION_REQUEST" | ./store_evolved_prompts.sh "$CATEGORY" "claude" &
            ./query_grok.sh "$EVOLUTION_REQUEST" | ./store_evolved_prompts.sh "$CATEGORY" "grok" &
        fi
    done
}

evolve_prompts
