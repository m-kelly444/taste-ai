#!/bin/bash

# Generate prompts based on recent discoveries about Chris

generate_discovery_prompts() {
    echo "🔍 Generating prompts based on recent discoveries..."
    
    # Get recent Chris discoveries
    RECENT_CHRIS_DATA=$(redis-cli -p 6381 -n 10 KEYS "*" | tail -50)
    RECENT_INVESTMENT_DATA=$(redis-cli -p 6381 -n 11 KEYS "*" | tail -20)
    RECENT_PSYCH_DATA=$(redis-cli -p 6381 -n 12 KEYS "*" | tail -20)
    
    # Sample some recent discoveries
    for data_key in $(echo "$RECENT_CHRIS_DATA" | head -10); do
        DISCOVERY=$(redis-cli -p 6381 -n 10 GET "$data_key" | jq -r '.content // .transcript // .analysis // "unknown"' 2>/dev/null | head -c 500)
        
        if [ ! -z "$DISCOVERY" ] && [ "$DISCOVERY" != "unknown" ]; then
            # Generate prompts based on this discovery
            DISCOVERY_PROMPT_REQUEST="Based on this new information about Chris Burch: '$DISCOVERY', generate 20 follow-up questions that would help us understand him deeper. Focus on psychological insights, decision patterns, and investment implications. Return as JSON array."
            
            ./query_chatgpt.sh "$DISCOVERY_PROMPT_REQUEST" | ./store_discovery_prompts.sh "chatgpt" &
            ./query_claude.sh "$DISCOVERY_PROMPT_REQUEST" | ./store_discovery_prompts.sh "claude" &
            ./query_grok.sh "$DISCOVERY_PROMPT_REQUEST" | ./store_discovery_prompts.sh "grok" &
        fi
    done
}

generate_discovery_prompts
