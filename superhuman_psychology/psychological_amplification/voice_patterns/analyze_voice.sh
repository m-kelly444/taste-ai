#!/bin/bash

echo "🎵 ANALYZING CHRIS BURCH VOICE PATTERNS"

analyze_vocal_signatures() {
    echo "🗣️ Analyzing vocal patterns..."
    
    VOICE_ANALYSIS_PROMPTS=(
        "Analyze Chris Burch's voice patterns: What does his tone, pace, and inflection reveal about his emotional state and decision-making?"
        "How does Chris Burch's speaking style change when he's excited about an investment opportunity vs. when he's skeptical?"
        "What vocal 'tells' does Chris Burch have that indicate his level of interest or confidence?"
        "Analyze Chris Burch's use of pauses, emphasis, and vocal fry - what do these patterns reveal psychologically?"
        "How does Chris Burch's voice change under stress or pressure?"
    )
    
    for prompt in "${VOICE_ANALYSIS_PROMPTS[@]}"; do
        ../../../chris_research_engine/query_chatgpt.sh "$prompt" | ./store_voice_pattern.sh "vocal_analysis" &
        ../../../chris_research_engine/query_claude.sh "$prompt" | ./store_voice_pattern.sh "vocal_analysis" &
        ../../../chris_research_engine/query_grok.sh "$prompt" | ./store_voice_pattern.sh "vocal_analysis" &
    done
}

# Execute voice analysis
analyze_vocal_signatures

wait
echo "✅ Voice pattern analysis complete"
