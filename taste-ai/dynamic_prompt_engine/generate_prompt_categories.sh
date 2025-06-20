#!/bin/bash

# Use LLMs to generate new categories of prompts to explore

generate_categories_with_llm() {
    echo "📂 Generating new prompt categories..."
    
    # Meta-prompt to generate categories (this is the ONLY hardcoded prompt!)
    CATEGORY_GENERATION_PROMPT="You are a prompt engineering expert. Generate 20 unique, creative categories of prompts that could be used to deeply analyze Chris Burch's psychology, business decisions, investment patterns, and personal preferences. Each category should explore a different aspect of understanding him. Be creative and think of categories that others might not consider. Return only a JSON array of category names."
    
    # Generate categories with each LLM
    CHATGPT_CATEGORIES=$(./query_chatgpt.sh "$CATEGORY_GENERATION_PROMPT" | jq -r '.choices[0].message.content // "[]"' 2>/dev/null || echo "[]")
    CLAUDE_CATEGORIES=$(./query_claude.sh "$CATEGORY_GENERATION_PROMPT" | jq -r '.content[0].text // "[]"' 2>/dev/null || echo "[]")
    GROK_CATEGORIES=$(./query_grok.sh "$CATEGORY_GENERATION_PROMPT" | jq -r '.choices[0].message.content // "[]"' 2>/dev/null || echo "[]")
    
    # Store all generated categories
    for categories in "$CHATGPT_CATEGORIES" "$CLAUDE_CATEGORIES" "$GROK_CATEGORIES"; do
        if [ "$categories" != "[]" ]; then
            CATEGORY_ID=$(echo "$categories$(date +%s%N)" | md5sum | cut -d' ' -f1)
            
            redis-cli -p 6381 -n $GENERATED_PROMPTS_DB SET "categories:$CATEGORY_ID" "{
                \"categories\": $categories,
                \"generated_at\": \"$(date -Iseconds)\",
                \"cycle\": $PROMPT_CYCLE
            }"
        fi
    done
    
    # Now use LLMs to generate MORE categories based on existing ones
    ./recursive_category_generation.sh &
}

generate_categories_with_llm
