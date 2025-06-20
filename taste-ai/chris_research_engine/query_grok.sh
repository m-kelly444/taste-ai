#!/bin/bash

QUERY="$1"
QUERY_ID=$(echo "$QUERY$(date +%s%N)" | md5sum | cut -d' ' -f1)

# If Grok API key is available
if [ ! -z "$GROK_API_KEY" ]; then
    # Note: Grok API endpoint may vary
    RESPONSE=$(curl -s https://api.x.ai/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GROK_API_KEY" \
        -d "{
            \"model\": \"grok-beta\",
            \"messages\": [
                {\"role\": \"user\", \"content\": \"Analyze Chris Burch in depth: $QUERY\"}
            ]
        }" 2>/dev/null)
    
    if [ ! -z "$RESPONSE" ]; then
        redis-cli -p 6381 -n $LLM_QUERIES_DB SET "grok:$QUERY_ID" "{
            \"query\": $(echo "$QUERY" | jq -R .),
            \"response\": $(echo "$RESPONSE" | jq -R .),
            \"llm\": \"grok\",
            \"timestamp\": \"$(date -Iseconds)\"
        }"
    fi
else
    echo "⚠️ Grok API key not available for Grok queries"
fi
