#!/bin/bash

# YouTube Chris Burch Deep Research

research_youtube_content() {
    echo "📺 Researching Chris Burch YouTube content..."
    
    # Search terms for Chris Burch content
    SEARCH_TERMS=(
        "chris burch interview"
        "chris burch tory burch"
        "chris burch fashion"
        "chris burch business"
        "chris burch entrepreneur"
        "chris burch investments"
        "chris burch venture capital"
        "burch creative capital"
        "chris burch style"
        "chris burch strategy"
        "chris burch leadership"
        "chris burch fashion week"
        "chris burch luxury brands"
        "chris burch retail"
        "chris burch ecommerce"
    )
    
    for term in "${SEARCH_TERMS[@]}"; do
        echo "🔍 Searching YouTube for: $term"
        
        # Use yt-dlp to get video metadata (install if needed)
        if command -v yt-dlp &> /dev/null; then
            # Get video list
            yt-dlp --dump-json --flat-playlist "ytsearch20:$term" 2>/dev/null | while read video_data; do
                if [ ! -z "$video_data" ]; then
                    VIDEO_ID=$(echo "$video_data" | jq -r '.id // empty' 2>/dev/null || echo "")
                    VIDEO_TITLE=$(echo "$video_data" | jq -r '.title // empty' 2>/dev/null || echo "")
                    
                    if [ ! -z "$VIDEO_ID" ] && [ ! -z "$VIDEO_TITLE" ]; then
                        # Check if we've already processed this video
                        if ! redis-cli -p 6381 -n $CHRIS_BURCH_DB EXISTS "youtube:$VIDEO_ID" >/dev/null; then
                            echo "📹 Processing new video: $VIDEO_TITLE"
                            
                            # Get full video metadata
                            VIDEO_META=$(yt-dlp --dump-json "https://youtube.com/watch?v=$VIDEO_ID" 2>/dev/null || echo "{}")
                            
                            # Extract transcript if available
                            TRANSCRIPT=$(yt-dlp --write-auto-sub --skip-download --sub-format vtt "https://youtube.com/watch?v=$VIDEO_ID" 2>/dev/null || echo "")
                            
                            # Store video data
                            redis-cli -p 6381 -n $CHRIS_BURCH_DB SET "youtube:$VIDEO_ID" "{
                                \"video_id\": \"$VIDEO_ID\",
                                \"title\": $(echo "$VIDEO_TITLE" | jq -R .),
                                \"search_term\": \"$term\",
                                \"metadata\": $VIDEO_META,
                                \"transcript\": $(echo "$TRANSCRIPT" | jq -R .),
                                \"discovered_at\": \"$(date -Iseconds)\",
                                \"research_cycle\": $RESEARCH_CYCLE
                            }"
                            
                            # Analyze video content for Chris insights
                            ./analyze_chris_video_content.sh "$VIDEO_ID" "$VIDEO_TITLE" "$TRANSCRIPT" &
                        fi
                    fi
                fi
            done
        else
            echo "⚠️ yt-dlp not installed, using alternative YouTube research..."
            # Alternative: use YouTube API or web scraping
            ./alternative_youtube_research.sh "$term" &
        fi
    done
}

research_youtube_content
