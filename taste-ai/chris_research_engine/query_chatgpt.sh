#!/bin/bash

QUERY="$1"
QUERY_ID=$(echo "$QUERY$(date +%s%N)" | md5sum | cut -d' ' -f1)

# If OpenAI API key is available
if [ ! -z "$OPENAI_API_KEY" ]; then
    RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
            \"model\": \"gpt-4\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"You are an expert analyst specializing in Chris Burch and his business ventures. Provide detailed, insightful analysis.\"},
                {\"role\": \"user\", \"content\": \"$QUERY\"}
            ]
        }" 2>/dev/null)
    
    if [ ! -z "$RESPONSE" ]; then
        redis-cli -p 6381 -n $LLM_QUERIES_DB SET "chatgpt:$QUERY_ID" "{
            \"query\": $(echo "$QUERY" | jq -R .),
            \"response\": $(echo "$RESPONSE" | jq -R .),
            \"llm\": \"chatgpt\",
            \"timestamp\": \"$(date -Iseconds)\"
        }"
    fi
else
    echo "⚠️ OpenAI API key not available for ChatGPT queries"
fi
