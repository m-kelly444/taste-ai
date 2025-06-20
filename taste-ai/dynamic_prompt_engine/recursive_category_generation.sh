#!/bin/bash

# Use existing categories to generate even more categories

recursive_generate() {
    echo "🔄 Recursively generating categories..."
    
    # Get existing categories
    EXISTING_CATEGORIES=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB KEYS "categories:*" | head -10)
    
    for category_key in $EXISTING_CATEGORIES; do
        CATEGORY_DATA=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB GET "$category_key")
        
        if [ ! -z "$CATEGORY_DATA" ]; then
            EXISTING_CATS=$(echo "$CATEGORY_DATA" | jq -r '.categories // "[]"')
            
            # Generate new categories inspired by existing ones
            EXPANSION_PROMPT="Based on these existing categories: $EXISTING_CATS, generate 15 completely new and different categories for analyzing Chris Burch that explore entirely different angles. Be wildly creative. Return only JSON array."
            
            # Generate with all LLMs
            ./query_chatgpt.sh "$EXPANSION_PROMPT" | ./store_generated_categories.sh "recursive_chatgpt" &
            ./query_claude.sh "$EXPANSION_PROMPT" | ./store_generated_categories.sh "recursive_claude" &
            ./query_grok.sh "$EXPANSION_PROMPT" | ./store_generated_categories.sh "recursive_grok" &
        fi
    done
}

recursive_generate
