#!/bin/bash

STREAM_ID=$1

# Trigger learning in keyword engine
redis-cli -p 6381 -n 1 PUBLISH keyword_learning_trigger "stream_$STREAM_ID"

# Trigger discovery engine
redis-cli -p 6381 -n 2 PUBLISH discovery_trigger "stream_$STREAM_ID"

# Trigger adaptive models
redis-cli -p 6381 -n 4 PUBLISH model_evolution_trigger "stream_$STREAM_ID"

# Trigger real-time processor
redis-cli -p 6381 -n 3 PUBLISH realtime_learning_trigger "stream_$STREAM_ID"

# Create learning connections between systems
./create_inter_system_connections.sh $STREAM_ID &
