#!/bin/bash

QUERY="$1"
QUERY_ID=$(echo "$QUERY$(date +%s%N)" | md5sum | cut -d' ' -f1)

# If Anthropic API key is available
if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -d "{
            \"model\": \"claude-3-opus-20240229\",
            \"max_tokens\": 1000,
            \"messages\": [
                {\"role\": \"user\", \"content\": \"As an expert on Chris Burch and his business empire, please analyze: $QUERY\"}
            ]
        }" 2>/dev/null)
    
    if [ ! -z "$RESPONSE" ]; then
        redis-cli -p 6381 -n $LLM_QUERIES_DB SET "claude:$QUERY_ID" "{
            \"query\": $(echo "$QUERY" | jq -R .),
            \"response\": $(echo "$RESPONSE" | jq -R .),
            \"llm\": \"claude\",
            \"timestamp\": \"$(date -Iseconds)\"
        }"
    fi
else
    echo "⚠️ Anthropic API key not available for Claude queries"
fi
