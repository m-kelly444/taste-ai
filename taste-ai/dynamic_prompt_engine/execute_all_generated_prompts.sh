#!/bin/bash

# Execute all generated prompts at massive scale

execute_prompts() {
    echo "⚡ Executing all generated prompts..."
    
    # Get all generated prompts
    ALL_PROMPT_KEYS=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB KEYS "prompts:*")
    ALL_META_PROMPTS=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB KEYS "meta_prompts:*")
    ALL_DISCOVERY_PROMPTS=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB KEYS "discovery_prompts:*")
    
    EXECUTION_BATCH=0
    
    # Execute regular prompts
    for prompt_key in $ALL_PROMPT_KEYS; do
        PROMPT_DATA=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB GET "$prompt_key")
        
        if [ ! -z "$PROMPT_DATA" ]; then
            PROMPTS=$(echo "$PROMPT_DATA" | jq -r '.prompts[]?' 2>/dev/null)
            
            while IFS= read -r prompt; do
                if [ ! -z "$prompt" ]; then
                    EXECUTION_BATCH=$((EXECUTION_BATCH + 1))
                    
                    # Execute this prompt with all LLMs
                    ./execute_single_prompt.sh "$prompt" "$EXECUTION_BATCH" &
                    
                    # Rate limiting - don't overwhelm APIs
                    if [ $((EXECUTION_BATCH % 100)) -eq 0 ]; then
                        wait
                        sleep 5
                    fi
                fi
            done <<< "$PROMPTS"
        fi
    done
    
    # Execute meta prompts
    for meta_key in $ALL_META_PROMPTS; do
        META_DATA=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB GET "$meta_key")
        
        if [ ! -z "$META_DATA" ]; then
            META_PROMPTS=$(echo "$META_DATA" | jq -r '.prompts[]?' 2>/dev/null)
            
            while IFS= read -r prompt; do
                if [ ! -z "$prompt" ]; then
                    EXECUTION_BATCH=$((EXECUTION_BATCH + 1))
                    ./execute_single_prompt.sh "$prompt" "$EXECUTION_BATCH" &
                    
                    if [ $((EXECUTION_BATCH % 50)) -eq 0 ]; then
                        wait
                        sleep 3
                    fi
                fi
            done <<< "$META_PROMPTS"
        fi
    done
    
    wait
    echo "✅ Executed $EXECUTION_BATCH prompts"
}

execute_prompts
