#!/bin/bash

STREAM_ID=$1

# Cross-connect learning between all systems
for source_db in {1..8}; do
    for target_db in {1..8}; do
        if [ $source_db -ne $target_db ]; then
            # Transfer top insights between databases
            SOURCE_KEY=$(redis-cli -p 6381 -n $source_db RANDOMKEY 2>/dev/null || echo "")
            if [ ! -z "$SOURCE_KEY" ]; then
                SOURCE_DATA=$(redis-cli -p 6381 -n $source_db GET "$SOURCE_KEY" 2>/dev/null || echo "{}")
                
                CONNECTION_ID=$(echo "$source_db$target_db$STREAM_ID$(date +%s%N)" | md5sum | cut -d' ' -f1)
                
                redis-cli -p 6381 -n $target_db SET "connection:$CONNECTION_ID" "{
                    \"source_db\": $source_db,
                    \"source_key\": \"$SOURCE_KEY\",
                    \"source_data\": $(echo "$SOURCE_DATA" | jq -R .),
                    \"stream_id\": $STREAM_ID,
                    \"connection_strength\": $(echo "scale=4; $RANDOM/32767" | bc),
                    \"timestamp\": \"$(date -Iseconds)\"
                }"
            fi
        fi
    done
done
