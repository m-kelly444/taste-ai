#!/bin/bash

# Continuous LLM Queries about Chris Burch

QUERY_CYCLE=0

query_llms_about_chris() {
    QUERY_CYCLE=$((QUERY_CYCLE + 1))
    echo "🤖 LLM Query Cycle $QUERY_CYCLE"
    
    # Generate sophisticated queries about Chris Burch
    CHRIS_QUERIES=(
        # Personality Analysis
        "Analyze Chris Burch's personality type based on his business decisions and public statements"
        "What are Chris Burch's core values based on his entrepreneurial journey?"
        "How does Chris Burch's communication style reflect his leadership approach?"
        "What personality traits make Chris Burch successful in fashion and investment?"
        "Analyze Chris Burch's risk tolerance based on his investment patterns"
        
        # Business Psychology
        "What motivates Chris Burch in his business ventures?"
        "How does Chris Burch approach decision-making in uncertain situations?"
        "What are Chris Burch's cognitive biases in business?"
        "How does Chris Burch handle failure and setbacks?"
        "What drives Chris Burch's entrepreneurial spirit?"
        
        # Investment Psychology
        "What psychological factors influence Chris Burch's investment decisions?"
        "How does Chris Burch evaluate potential investments?"
        "What are Chris Burch's investment blind spots?"
        "How does emotion vs logic play into Chris Burch's investment strategy?"
        "What patterns exist in Chris Burch's successful vs failed investments?"
        
        # Strategic Thinking
        "How does Chris Burch think about market timing?"
        "What is Chris Burch's approach to competitive analysis?"
        "How does Chris Burch identify emerging trends?"
        "What is Chris Burch's framework for evaluating business models?"
        "How does Chris Burch approach international expansion?"
        
        # Leadership Style
        "How does Chris Burch build and manage teams?"
        "What is Chris Burch's approach to delegation?"
        "How does Chris Burch handle conflict resolution?"
        "What motivates Chris Burch's employees and partners?"
        "How does Chris Burch approach mentorship and development?"
        
        # Fashion Industry Insights
        "What does Chris Burch understand about fashion consumer psychology?"
        "How does Chris Burch predict fashion trends?"
        "What is Chris Burch's view on the future of fashion retail?"
        "How does Chris Burch approach brand building in fashion?"
        "What are Chris Burch's insights on luxury vs accessible fashion?"
    )
    
    # Query each LLM with different approaches
    for query in "${CHRIS_QUERIES[@]}"; do
        echo "❓ Querying: $query"
        
        # Query ChatGPT via API (if available)
        ./query_chatgpt.sh "$query" &
        
        # Query Claude via API (if available)
        ./query_claude.sh "$query" &
        
        # Query Grok via API (if available)
        ./query_grok.sh "$query" &
        
        # Generate follow-up questions
        ./generate_followup_queries.sh "$query" &
        
        sleep 1
    done
    
    # Generate dynamic queries based on recent discoveries
    ./generate_dynamic_chris_queries.sh &
}

query_llms_about_chris
