#!/bin/bash

# Dynamic Prompt Generation - No Hardcoded Prompts!
PROMPT_CYCLE=0
GENERATED_PROMPTS_DB=20

generate_infinite_prompts() {
    while true; do
        PROMPT_CYCLE=$((PROMPT_CYCLE + 1))
        echo "🚀 Prompt Generation Cycle $PROMPT_CYCLE - $(date)"
        
        # Use LLMs to generate new prompt categories
        ./generate_prompt_categories.sh &
        
        # Use LLMs to generate prompts within each category
        ./generate_category_prompts.sh &
        
        # Use LLMs to evolve existing prompts
        ./evolve_existing_prompts.sh &
        
        # Use LLMs to create meta-prompts (prompts about prompts)
        ./generate_meta_prompts.sh &
        
        # Use LLMs to generate prompts based on recent discoveries
        ./generate_discovery_based_prompts.sh &
        
        # Use LLMs to create psychological analysis prompts
        ./generate_psychological_prompts.sh &
        
        # Use LLMs to create investment analysis prompts
        ./generate_investment_prompts.sh &
        
        # Use LLMs to generate creative/unexpected prompts
        ./generate_creative_prompts.sh &
        
        wait
        
        # Execute all generated prompts
        ./execute_all_generated_prompts.sh &
        
        sleep 30  # Generate new prompts every 30 seconds
    done
}

generate_infinite_prompts
