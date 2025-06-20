#!/bin/bash

while true; do
    clear
    echo "Model Evolution Monitor - $(date)"
    echo "======================================"
    
    REPORT=$(redis-cli -p 6381 -n 4 GET model_performance_report 2>/dev/null)
    
    if [ ! -z "$REPORT" ]; then
        echo "$REPORT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'Generation: {data[\"generation\"]}')
    print(f'Population: {data[\"population_size\"]} models')
    print()
    print('Top Models:')
    models = data['models']
    sorted_models = sorted(models.items(), key=lambda x: x[1]['recent_fitness'], reverse=True)
    for i, (model_id, model_data) in enumerate(sorted_models[:5]):
        print(f'  {i+1}. {model_id}')
        print(f'     Architecture: {model_data[\"architecture\"]}')
        print(f'     Recent Fitness: {model_data[\"recent_fitness\"]:.4f}')
        print(f'     Average Fitness: {model_data[\"average_fitness\"]:.4f}')
        print()
except Exception as e:
    print(f'Error parsing report: {e}')
"
    else
        echo "No performance report available yet"
    fi
    
    echo ""
    ENSEMBLE=$(redis-cli -p 6381 -n 4 GET ensemble_configuration 2>/dev/null)
    if [ ! -z "$ENSEMBLE" ]; then
        echo "Current Ensemble:"
        echo "$ENSEMBLE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    models = data['models']
    weights = data['weights']
    for model_id in models:
        weight = weights.get(model_id, 0.0)
        print(f'  {model_id}: {weight:.3f}')
except:
    pass
"
    fi
    
    echo ""
    if pgrep -f "adaptive_model_engine.py" > /dev/null; then
        echo "Status: EVOLVING MODELS"
    else
        echo "Status: STOPPED"
    fi
    
    sleep 15
done
