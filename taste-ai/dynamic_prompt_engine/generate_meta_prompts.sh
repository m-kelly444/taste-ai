#!/bin/bash

# Generate prompts about prompts - meta-level analysis

generate_meta_prompts() {
    echo "🔮 Generating meta-prompts..."
    
    # Generate prompts that ask about how to ask better questions
    META_PROMPT_REQUESTS=(
        "Generate 25 prompts that would help us understand what we don't know about Chris Burch - prompts that reveal our blind spots"
        "Create 25 prompts that would help us ask better questions about Chris Burch's decision-making process"
        "Generate 25 prompts that would reveal hidden patterns in Chris Burch's behavior that we haven't considered"
        "Create 25 prompts that would help us understand Chris Burch from perspectives we haven't explored"
        "Generate 25 prompts that would help us predict Chris Burch's future decisions better"
    )
    
    for request in "${META_PROMPT_REQUESTS[@]}"; do
        # Generate with all LLMs
        ./query_chatgpt.sh "$request" | ./store_meta_prompts.sh "chatgpt" &
        ./query_claude.sh "$request" | ./store_meta_prompts.sh "claude" &
        ./query_grok.sh "$request" | ./store_meta_prompts.sh "grok" &
    done
}

generate_meta_prompts
