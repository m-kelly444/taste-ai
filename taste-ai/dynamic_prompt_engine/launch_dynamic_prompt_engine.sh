#!/bin/bash
set -e

echo "🚀 LAUNCHING DYNAMIC PROMPT GENERATION ENGINE"
echo "============================================"

# Initialize prompt generation database
echo "🗄️ Initializing dynamic prompt database..."
redis-cli -p 6381 -n $GENERATED_PROMPTS_DB FLUSHDB
redis-cli -p 6381 -n $GENERATED_PROMPTS_DB SET "db_purpose" "dynamic_prompt_generation"

echo "🧠 Starting Dynamic Prompt Generator..."
./dynamic_prompt_generator.sh &
GENERATOR_PID=$!

echo "📊 Starting Prompt Quality Evaluator..."
while true; do
    ./evaluate_prompt_quality.sh
    sleep 300  # Evaluate every 5 minutes
done &
EVALUATOR_PID=$!

echo "🧠 Starting Adaptive Prompt Learning..."
while true; do
    ./adaptive_prompt_learning.sh
    sleep 600  # Learn every 10 minutes
done &
LEARNER_PID=$!

echo "📊 Starting Dynamic Monitoring..."
./monitor_dynamic_prompts.sh &
MONITOR_PID=$!

echo "✅ DYNAMIC PROMPT GENERATION ENGINE LAUNCHED"
echo "==========================================="
echo
echo "🚀 REVOLUTIONARY FEATURES:"
echo "  • ZERO hardcoded prompts"
echo "  • LLMs generate their own prompt categories"
echo "  • LLMs generate millions of prompts dynamically"
echo "  • Prompts evolve and improve automatically"
echo "  • Meta-prompts generate prompts about prompts"
echo "  • Quality evaluation improves future generation"
echo "  • Adaptive learning from successful patterns"
echo
echo "🎯 SCALE:"
echo "  • Millions of prompts per day"
echo "  • Continuous prompt evolution"
echo "  • No assumptions about what works"
echo "  • Truly intelligent prompt discovery"
echo
echo "PIDs:"
echo "  Generator: $GENERATOR_PID"
echo "  Evaluator: $EVALUATOR_PID"
echo "  Learner: $LEARNER_PID"
echo "  Monitor: $MONITOR_PID"

# Store PIDs
echo "$GENERATOR_PID,$EVALUATOR_PID,$LEARNER_PID,$MONITOR_PID" > dynamic_prompt_engine.pids

echo
echo "🧠 The system is now generating prompts dynamically with no hardcoding!"
echo "📊 Monitor: ./monitor_dynamic_prompts.sh"
echo "🛑 Stop all: kill $GENERATOR_PID $EVALUATOR_PID $LEARNER_PID $MONITOR_PID"

wait $GENERATOR_PID
