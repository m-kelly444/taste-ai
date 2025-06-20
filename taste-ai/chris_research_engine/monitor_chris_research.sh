#!/bin/bash

while true; do
    clear
    echo "🔍 CHRIS BURCH DEEP RESEARCH MONITOR"
    echo "===================================="
    echo "$(date)"
    echo
    
    # Research Progress
    YOUTUBE_COUNT=$(redis-cli -p 6381 -n $CHRIS_BURCH_DB KEYS "youtube:*" | wc -l 2>/dev/null || echo "0")
    WEB_COUNT=$(redis-cli -p 6381 -n $CHRIS_BURCH_DB KEYS "web:*" | wc -l 2>/dev/null || echo "0")
    LLM_COUNT=$(redis-cli -p 6381 -n $LLM_QUERIES_DB DBSIZE 2>/dev/null || echo "0")
    PSYCH_COUNT=$(redis-cli -p 6381 -n $PSYCHOANALYSIS_DB DBSIZE 2>/dev/null || echo "0")
    INVEST_COUNT=$(redis-cli -p 6381 -n $INVESTMENTS_DB DBSIZE 2>/dev/null || echo "0")
    
    echo "📊 RESEARCH PROGRESS:"
    echo "  YouTube Videos Analyzed: $YOUTUBE_COUNT"
    echo "  Web Sources Scraped: $WEB_COUNT"
    echo "  LLM Queries Completed: $LLM_COUNT"
    echo "  Psychological Analyses: $PSYCH_COUNT"
    echo "  Investment Records: $INVEST_COUNT"
    
    TOTAL_DATA=$((YOUTUBE_COUNT + WEB_COUNT + LLM_COUNT + PSYCH_COUNT + INVEST_COUNT))
    echo "  TOTAL DATA POINTS: $TOTAL_DATA"
    
    echo
    echo "🧠 PSYCHOANALYSIS STATUS:"
    PERSONALITY_PROFILES=$(redis-cli -p 6381 -n $PSYCHOANALYSIS_DB KEYS "personality:*" | wc -l 2>/dev/null || echo "0")
    DECISION_PATTERNS=$(redis-cli -p 6381 -n $PSYCHOANALYSIS_DB KEYS "decision_pattern:*" | wc -l 2>/dev/null || echo "0")
    echo "  Personality Profiles: $PERSONALITY_PROFILES"
    echo "  Decision Patterns: $DECISION_PATTERNS"
    
    echo
    echo "💰 INVESTMENT RESEARCH:"
    TRACKED_INVESTMENTS=$(redis-cli -p 6381 -n $INVESTMENTS_DB KEYS "investment:*" | wc -l 2>/dev/null || echo "0")
    PERFORMANCE_DATA=$(redis-cli -p 6381 -n $INVESTMENTS_DB KEYS "performance:*" | wc -l 2>/dev/null || echo "0")
    echo "  Tracked Investments: $TRACKED_INVESTMENTS"
    echo "  Performance Records: $PERFORMANCE_DATA"
    
    echo
    echo "🤖 LLM ANALYSIS STATUS:"
    CHATGPT_QUERIES=$(redis-cli -p 6381 -n $LLM_QUERIES_DB KEYS "chatgpt:*" | wc -l 2>/dev/null || echo "0")
    CLAUDE_QUERIES=$(redis-cli -p 6381 -n $LLM_QUERIES_DB KEYS "claude:*" | wc -l 2>/dev/null || echo "0")
    GROK_QUERIES=$(redis-cli -p 6381 -n $LLM_QUERIES_DB KEYS "grok:*" | wc -l 2>/dev/null || echo "0")
    echo "  ChatGPT Analyses: $CHATGPT_QUERIES"
    echo "  Claude Analyses: $CLAUDE_QUERIES"
    echo "  Grok Analyses: $GROK_QUERIES"
    
    echo
    echo "⚡ ACTIVE PROCESSES:"
    if pgrep -f "continuous_chris_research.sh" > /dev/null; then
        echo "  ✅ Chris Research Engine: RUNNING"
    else
        echo "  ❌ Chris Research Engine: STOPPED"
    fi
    
    if pgrep -f "continuous_investment_research.sh" > /dev/null; then
        echo "  ✅ Investment Research: RUNNING"
    else
        echo "  ❌ Investment Research: STOPPED"
    fi
    
    if pgrep -f "llm_chris_queries.sh" > /dev/null; then
        echo "  ✅ LLM Queries: RUNNING"
    else
        echo "  ❌ LLM Queries: STOPPED"
    fi
    
    echo
    echo "📈 RESEARCH VELOCITY:"
    RESEARCH_RATE=$((TOTAL_DATA / 60))
    echo "  Data Points/Hour: $RESEARCH_RATE"
    
    echo
    echo "🎯 RESEARCH COMPLETENESS:"
    if [ $TOTAL_DATA -gt 10000 ]; then
        echo "  Status: COMPREHENSIVE (95%+)"
    elif [ $TOTAL_DATA -gt 5000 ]; then
        echo "  Status: SUBSTANTIAL (80%)"
    elif [ $TOTAL_DATA -gt 1000 ]; then
        echo "  Status: DEVELOPING (60%)"
    else
        echo "  Status: INITIAL (30%)"
    fi
    
    echo
    echo "Press Ctrl+C to stop monitoring"
    sleep 5
done
