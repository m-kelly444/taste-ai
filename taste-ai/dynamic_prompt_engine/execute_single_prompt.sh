#!/bin/bash

PROMPT="$1"
BATCH_ID="$2"

execute_prompt() {
    # Execute this prompt with all available LLMs
    PROMPT_ID=$(echo "$PROMPT$BATCH_ID$(date +%s%N)" | md5sum | cut -d' ' -f1)
    
    # ChatGPT execution
    if [ ! -z "$OPENAI_API_KEY" ]; then
        CHATGPT_RESPONSE=$(./query_chatgpt.sh "$PROMPT" 2>/dev/null)
        
        if [ ! -z "$CHATGPT_RESPONSE" ]; then
            redis-cli -p 6381 -n $LLM_QUERIES_DB SET "response:chatgpt:$PROMPT_ID" "{
                \"prompt\": $(echo "$PROMPT" | jq -R .),
                \"response\": $(echo "$CHATGPT_RESPONSE" | jq -R .),
                \"llm\": \"chatgpt\",
                \"batch_id\": \"$BATCH_ID\",
                \"executed_at\": \"$(date -Iseconds)\"
            }"
        fi
    fi
    
    # Claude execution
    if [ ! -z "$ANTHROPIC_API_KEY" ]; then
        CLAUDE_RESPONSE=$(./query_claude.sh "$PROMPT" 2>/dev/null)
        
        if [ ! -z "$CLAUDE_RESPONSE" ]; then
            redis-cli -p 6381 -n $LLM_QUERIES_DB SET "response:claude:$PROMPT_ID" "{
                \"prompt\": $(echo "$PROMPT" | jq -R .),
                \"response\": $(echo "$CLAUDE_RESPONSE" | jq -R .),
                \"llm\": \"claude\",
                \"batch_id\": \"$BATCH_ID\",
                \"executed_at\": \"$(date -Iseconds)\"
            }"
        fi
    fi
    
    # Grok execution
    if [ ! -z "$GROK_API_KEY" ]; then
        GROK_RESPONSE=$(./query_grok.sh "$PROMPT" 2>/dev/null)
        
        if [ ! -z "$GROK_RESPONSE" ]; then
            redis-cli -p 6381 -n $LLM_QUERIES_DB SET "response:grok:$PROMPT_ID" "{
                \"prompt\": $(echo "$PROMPT" | jq -R .),
                \"response\": $(echo "$GROK_RESPONSE" | jq -R .),
                \"llm\": \"grok\",
                \"batch_id\": \"$BATCH_ID\",
                \"executed_at\": \"$(date -Iseconds)\"
            }"
        fi
    fi
}

execute_prompt
