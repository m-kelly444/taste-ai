#!/bin/bash
set -e

echo "🔍 COLLECTING CHRIS BURCH DATA - PHASE 1"
echo "========================================"

# Determine Redis command
if command -v redis-cli &> /dev/null; then
    REDIS_CMD="redis-cli"
else
    REDIS_CMD="docker exec chris-analysis-redis redis-cli"
fi

# Create data collection log
LOG_FILE="chris_analysis/data/collection_$(date +%Y%m%d_%H%M%S).log"
touch "$LOG_FILE"

echo "📋 Starting systematic data collection..." | tee -a "$LOG_FILE"

# Known Chris Burch data sources to collect
declare -a SOURCES=(
    "https://www.burchcreativecapital.com"
    "https://en.wikipedia.org/wiki/J._Christopher_Burch"
    "https://www.crunchbase.com/person/j-christopher-burch"
    "https://www.linkedin.com/in/christopher-burch-116531123"
    "https://www.bjtonline.com/business-jet-news/billionaire-chris-burch"
    "https://www.prnewswire.com/news-releases/burch-creative-capital-announces-new-and-follow-on-investments-to-founder-chris-burchs-portfolio-300389216.html"
)

# Collect data from each source
for i in "${!SOURCES[@]}"; do
    SOURCE="${SOURCES[$i]}"
    echo "🌐 Collecting from source $((i+1))/${#SOURCES[@]}: $SOURCE" | tee -a "$LOG_FILE"
    
    # Create unique filename for this source
    FILENAME="chris_analysis/sources/web/source_$((i+1))_$(date +%H%M%S).html"
    
    # Download content (with timeout and user agent)
    if curl -L -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
        --connect-timeout 10 --max-time 30 \
        -o "$FILENAME" "$SOURCE" 2>/dev/null; then
        
        echo "  ✅ Downloaded: $(wc -c < "$FILENAME") bytes" | tee -a "$LOG_FILE"
        
        # Store source info in Redis
        $REDIS_CMD SELECT 10
        $REDIS_CMD HSET "sources:web:$i" \
            "url" "$SOURCE" \
            "filename" "$FILENAME" \
            "collected_at" "$(date -Iseconds)" \
            "size_bytes" "$(wc -c < "$FILENAME")" \
            "status" "collected"
        
        # Update collection progress
        COLLECTED=$($REDIS_CMD HGET "chris_analysis:progress" "sources_collected")
        $REDIS_CMD HSET "chris_analysis:progress" "sources_collected" "$((${COLLECTED:-0} + 1))"
        
    else
        echo "  ❌ Failed to download from $SOURCE" | tee -a "$LOG_FILE"
        $REDIS_CMD HSET "sources:web:$i" \
            "url" "$SOURCE" \
            "status" "failed" \
            "attempted_at" "$(date -Iseconds)"
    fi
    
    # Brief delay to be respectful
    sleep 2
done

# Search for interviews and podcast appearances
echo "🎤 Searching for Chris Burch interviews..." | tee -a "$LOG_FILE"

# Known interview keywords to search for
INTERVIEW_KEYWORDS=(
    "chris burch interview"
    "christopher burch podcast"
    "chris burch speaks"
    "burch creative capital interview"
    "chris burch entrepreneurship"
)

# Create search results file
SEARCH_RESULTS="chris_analysis/data/interview_search_results.txt"
echo "# Chris Burch Interview Search Results - $(date)" > "$SEARCH_RESULTS"

for keyword in "${INTERVIEW_KEYWORDS[@]}"; do
    echo "🔎 Searching for: $keyword" | tee -a "$LOG_FILE"
    echo "## Search: $keyword" >> "$SEARCH_RESULTS"
    
    # Note: In a real implementation, you would use APIs like:
    # - YouTube Data API for video interviews
    # - Podcast Index API for podcast appearances  
    # - Google Custom Search API for web results
    # For now, we'll create placeholders for manual collection
    
    echo "TODO: Manual search required for '$keyword'" >> "$SEARCH_RESULTS"
    echo "  - Check YouTube for video interviews" >> "$SEARCH_RESULTS"
    echo "  - Check podcast platforms (Spotify, Apple Podcasts)" >> "$SEARCH_RESULTS"
    echo "  - Check business publication interviews" >> "$SEARCH_RESULTS"
    echo "" >> "$SEARCH_RESULTS"
done

# Update Redis with search tasks
$REDIS_CMD SELECT 10
$REDIS_CMD SET "interview_searches:status" "manual_collection_required"
$REDIS_CMD SET "interview_searches:keywords" "$(printf '%s,' "${INTERVIEW_KEYWORDS[@]}" | sed 's/,$//')"

# Summary
SOURCES_COLLECTED=$($REDIS_CMD HGET "chris_analysis:progress" "sources_collected")
echo "" | tee -a "$LOG_FILE"
echo "📊 COLLECTION SUMMARY:" | tee -a "$LOG_FILE"
echo "  Sources collected: ${SOURCES_COLLECTED:-0}/${#SOURCES[@]}" | tee -a "$LOG_FILE"
echo "  Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "  Search results: $SEARCH_RESULTS" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "🎯 Next: Run text analysis script to extract insights from collected data" | tee -a "$LOG_FILE"