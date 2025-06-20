#!/bin/bash
set -e

echo "🔍 LAUNCHING CHRIS BURCH DEEP RESEARCH ENGINE"
echo "============================================"

# Initialize Redis databases
echo "🗄️ Initializing research databases..."
redis-cli -p 6381 -n $CHRIS_BURCH_DB FLUSHDB
redis-cli -p 6381 -n $INVESTMENTS_DB FLUSHDB
redis-cli -p 6381 -n $PSYCHOANALYSIS_DB FLUSHDB
redis-cli -p 6381 -n $LLM_QUERIES_DB FLUSHDB

# Set database purposes
redis-cli -p 6381 -n $CHRIS_BURCH_DB SET "db_purpose" "chris_burch_research"
redis-cli -p 6381 -n $INVESTMENTS_DB SET "db_purpose" "investment_research"
redis-cli -p 6381 -n $PSYCHOANALYSIS_DB SET "db_purpose" "psychological_analysis"
redis-cli -p 6381 -n $LLM_QUERIES_DB SET "db_purpose" "llm_queries"

echo "👤 Starting Chris Burch Research Engine..."
./continuous_chris_research.sh &
CHRIS_PID=$!

echo "💰 Starting Investment Research Engine..."
./continuous_investment_research.sh &
INVEST_PID=$!

echo "📊 Starting Research Monitor..."
./monitor_chris_research.sh &
MONITOR_PID=$!

echo "✅ CHRIS BURCH DEEP RESEARCH ENGINE LAUNCHED"
echo "==========================================="
echo
echo "🔍 RESEARCH COMPONENTS ACTIVE:"
echo "  • Continuous YouTube video analysis"
echo "  • Real-time web scraping"
echo "  • Multi-LLM psychological analysis"
echo "  • Investment pattern tracking"
echo "  • News and social media monitoring"
echo "  • Comprehensive psychoanalysis"
echo "  • Investment performance tracking"
echo
echo "🤖 LLM INTEGRATION:"
echo "  • ChatGPT continuous queries"
echo "  • Claude psychological analysis"
echo "  • Grok market insights"
echo
echo "📊 MONITORING:"
echo "  • Real-time research progress"
echo "  • Data quality metrics"
echo "  • Research completeness tracking"
echo
echo "PIDs:"
echo "  Chris Research: $CHRIS_PID"
echo "  Investment Research: $INVEST_PID"
echo "  Monitor: $MONITOR_PID"

# Store PIDs
echo "$CHRIS_PID,$INVEST_PID,$MONITOR_PID" > chris_research_engine.pids

echo
echo "🎯 The system will continuously learn about Chris Burch until stopped"
echo "📊 Monitor progress: ./monitor_chris_research.sh"
echo "🛑 Stop: kill $CHRIS_PID $INVEST_PID $MONITOR_PID"

wait $CHRIS_PID
