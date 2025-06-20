#!/bin/bash

# For each category, generate hundreds of specific prompts

generate_prompts_for_categories() {
    echo "💡 Generating prompts for each category..."
    
    # Get all categories
    ALL_CATEGORIES=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB KEYS "categories:*")
    
    for category_key in $ALL_CATEGORIES; do
        CATEGORY_DATA=$(redis-cli -p 6381 -n $GENERATED_PROMPTS_DB GET "$category_key")
        
        if [ ! -z "$CATEGORY_DATA" ]; then
            CATEGORIES=$(echo "$CATEGORY_DATA" | jq -r '.categories[]' 2>/dev/null)
            
            # For each category, generate specific prompts
            while IFS= read -r category; do
                if [ ! -z "$category" ]; then
                    ./generate_prompts_for_single_category.sh "$category" &
                fi
            done <<< "$CATEGORIES"
        fi
    done
}

generate_prompts_for_categories
