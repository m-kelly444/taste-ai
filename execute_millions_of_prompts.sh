#!/bin/bash

echo "🚀 EXECUTING MILLIONS OF PROMPTS DAILY"
echo "====================================="

DAILY_PROMPT_TARGET=1000000
PROMPTS_EXECUTED=0

while [ $PROMPTS_EXECUTED -lt $DAILY_PROMPT_TARGET ]; do
    
    # Get all generated prompts from all systems
    ALL_PROMPTS=$(redis-cli -p 6381 -n 20 KEYS "prompts:*" | wc -l)
    
    echo "📊 Available prompts: $ALL_PROMPTS"
    echo "📈 Executed today: $PROMPTS_EXECUTED / $DAILY_PROMPT_TARGET"
    
    # Execute prompts in parallel batches
    BATCH_SIZE=1000
    
    for ((i=0; i<$BATCH_SIZE; i++)); do
        # Get random prompt
        RANDOM_PROMPT_KEY=$(redis-cli -p 6381 -n 20 RANDOMKEY)
        
        if [ ! -z "$RANDOM_PROMPT_KEY" ]; then
            PROMPT_DATA=$(redis-cli -p 6381 -n 20 GET "$RANDOM_PROMPT_KEY")
            PROMPT=$(echo "$PROMPT_DATA" | jq -r '.prompts[0]' 2>/dev/null)
            
            if [ ! -z "$PROMPT" ]; then
                # Execute with all LLMs in parallel
                ./execute_single_prompt.sh "$PROMPT" &
                PROMPTS_EXECUTED=$((PROMPTS_EXECUTED + 1))
            fi
        fi
    done
    
    # Wait for batch to complete
    wait
    
    # Brief pause between batches
    sleep 1
    
    echo "⚡ Batch complete. Total executed: $PROMPTS_EXECUTED"
done

echo "🎯 TARGET REACHED: $DAILY_PROMPT_TARGET prompts executed!"
