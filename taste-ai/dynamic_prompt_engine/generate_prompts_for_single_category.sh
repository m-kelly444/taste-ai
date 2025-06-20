#!/bin/bash

CATEGORY="$1"

generate_category_specific_prompts() {
    echo "🎯 Generating prompts for category: $CATEGORY"
    
    # Generate prompts for this specific category
    PROMPT_GENERATION_REQUEST="Generate 50 highly specific, detailed prompts for analyzing Chris Burch in the category of '$CATEGORY'. Each prompt should be unique, insightful, and designed to extract deep understanding. Make them vary in approach - some direct, some indirect, some comparative, some hypothetical. Return as JSON array of strings."
    
    # Generate with all LLMs
    CHATGPT_PROMPTS=$(./query_chatgpt.sh "$PROMPT_GENERATION_REQUEST" | jq -r '.choices[0].message.content // "[]"' 2>/dev/null || echo "[]")
    CLAUDE_PROMPTS=$(./query_claude.sh "$PROMPT_GENERATION_REQUEST" | jq -r '.content[0].text // "[]"' 2>/dev/null || echo "[]")
    GROK_PROMPTS=$(./query_grok.sh "$PROMPT_GENERATION_REQUEST" | jq -r '.choices[0].message.content // "[]"' 2>/dev/null || echo "[]")
    
    # Store all generated prompts
    for prompts in "$CHATGPT_PROMPTS" "$CLAUDE_PROMPTS" "$GROK_PROMPTS"; do
        if [ "$prompts" != "[]" ]; then
            PROMPT_SET_ID=$(echo "$prompts$CATEGORY$(date +%s%N)" | md5sum | cut -d' ' -f1)
            
            redis-cli -p 6381 -n $GENERATED_PROMPTS_DB SET "prompts:$CATEGORY:$PROMPT_SET_ID" "{
                \"category\": \"$CATEGORY\",
                \"prompts\": $prompts,
                \"generated_at\": \"$(date -Iseconds)\",
                \"cycle\": $PROMPT_CYCLE
            }"
        fi
    done
    
    # Generate variations of these prompts
    ./generate_prompt_variations.sh "$CATEGORY" "$CHATGPT_PROMPTS" &
}

generate_category_specific_prompts
