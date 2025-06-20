#!/bin/bash

# Comprehensive Web Scraping for Chris Burch

scrape_chris_sources() {
    echo "🌐 Scraping web sources for Chris Burch..."
    
    # Primary sources to scrape
    CHRIS_SOURCES=(
        "https://www.burchcreativecapital.com"
        "https://www.toryburch.com"
        "https://www.crunchbase.com/person/chris-burch"
        "https://www.forbes.com/profile/chris-burch/"
        "https://www.bloomberg.com/billionaires/profiles/christopher-burch/"
        "https://en.wikipedia.org/wiki/Chris_Burch"
        "https://www.linkedin.com/in/chris-burch"
    )
    
    # News and article sources
    NEWS_SOURCES=(
        "https://www.businessinsider.com"
        "https://www.cnbc.com"
        "https://www.reuters.com"
        "https://www.wsj.com"
        "https://www.nytimes.com"
        "https://www.ft.com"
        "https://www.vogue.com"
        "https://www.wwd.com"
        "https://www.businessoffashion.com"
    )
    
    for source in "${CHRIS_SOURCES[@]}"; do
        echo "🔍 Scraping: $source"
        
        # Use curl with user agent rotation
        USER_AGENTS=(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
        )
        
        RANDOM_UA=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}
        
        CONTENT=$(curl -s --user-agent "$RANDOM_UA" --timeout 30 "$source" 2>/dev/null || echo "")
        
        if [ ! -z "$CONTENT" ]; then
            # Extract and store content
            CONTENT_HASH=$(echo "$CONTENT" | md5sum | cut -d' ' -f1)
            
            redis-cli -p 6381 -n $CHRIS_BURCH_DB SET "web:$CONTENT_HASH" "{
                \"source_url\": \"$source\",
                \"content\": $(echo "$CONTENT" | jq -R -s .),
                \"scraped_at\": \"$(date -Iseconds)\",
                \"content_length\": ${#CONTENT}
            }"
            
            # Extract Chris-specific information
            ./extract_chris_info.sh "$CONTENT" "$source" &
        fi
        
        # Rate limiting
        sleep 2
    done
    
    # Search for Chris Burch mentions across news sources
    for news_source in "${NEWS_SOURCES[@]}"; do
        ./search_news_for_chris.sh "$news_source" &
    done
}

scrape_chris_sources
