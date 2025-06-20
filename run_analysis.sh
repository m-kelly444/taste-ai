#!/bin/bash

# Main analysis runner - executes all steps in sequence
echo "🚀 Starting portfolio analysis pipeline..."

# Check if data directory exists
if [ ! -d "./data" ]; then
    mkdir -p data/{portfolio,analysis,images,logs}
fi

# Run scripts in sequence
echo "Step 1: Fetching portfolio page..."
./01_fetch_portfolio.sh 2>&1 | tee data/logs/01_fetch.log

echo "Step 2: Parsing portfolio..."  
./02_parse_portfolio.sh 2>&1 | tee data/logs/02_parse.log

echo "Step 3: Cleaning company names..."
./03_clean_company_names.sh 2>&1 | tee data/logs/03_clean.log

echo "Step 4: Deep extraction..."
./04_deep_portfolio_extraction.sh 2>&1 | tee data/logs/04_deep.log

echo "Step 5: Visual analysis..."
./05_real_visual_analysis.sh 2>&1 | tee data/logs/05_visual.log

echo "✅ Analysis pipeline complete!"
echo "📊 Check data/analysis/ for results"
