#!/usr/bin/env python3
"""
Continuous Learning Engine - Core Intelligence System
Implements real-time model updates and recursive self-improvement
"""

import asyncio
import numpy as np
import torch
import redis
import json
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
import logging

@dataclass
class IntelligenceUpdate:
    """Represents a single learning update"""
    source: str  # 'chris_feedback', 'market_data', 'investment_outcome'
    data: Dict
    confidence: float
    timestamp: datetime
    impact_score: float

class ContinuousLearningEngine:
    def __init__(self):
        self.redis_client = redis.Redis(host='localhost', port=6381, db=0)
        self.learning_queue = asyncio.Queue()
        self.model_versions = {}
        self.update_threshold = 0.1
        self.chris_weight_multiplier = 3.0  # Chris's input is 3x more important
        
        # Initialize logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
    async def start_continuous_learning(self):
        """Main learning loop - runs 24/7"""
        self.logger.info("🚀 Starting continuous learning engine...")
        
        # Start parallel learning processes
        await asyncio.gather(
            self.data_ingestion_loop(),
            self.model_update_loop(),
            self.feedback_processing_loop(),
            self.performance_monitoring_loop()
        )
    
    async def data_ingestion_loop(self):
        """Continuously ingest new data from multiple sources"""
        while True:
            try:
                # Check for new data from multiple sources
                await self.ingest_chris_interactions()
                await self.ingest_market_movements()
                await self.ingest_social_signals()
                await self.ingest_investment_outcomes()
                
                await asyncio.sleep(30)  # Check every 30 seconds
                
            except Exception as e:
                self.logger.error(f"Data ingestion error: {e}")
                await asyncio.sleep(60)
    
    async def ingest_chris_interactions(self):
        """Ingest Chris Burch's direct interactions and feedback"""
        # Check Redis for new Chris interactions
        chris_updates = self.redis_client.lrange('chris_interactions', 0, -1)
        
        for update_data in chris_updates:
            try:
                data = json.loads(update_data)
                
                # Create high-priority learning update
                update = IntelligenceUpdate(
                    source='chris_feedback',
                    data=data,
                    confidence=0.95,  # Chris's input is high confidence
                    timestamp=datetime.now(),
                    impact_score=data.get('impact_score', 1.0) * self.chris_weight_multiplier
                )
                
                await self.learning_queue.put(update)
                self.logger.info(f"💎 Chris interaction processed: {data.get('type', 'unknown')}")
                
            except Exception as e:
                self.logger.error(f"Error processing Chris interaction: {e}")
        
        # Clear processed items
        if chris_updates:
            self.redis_client.delete('chris_interactions')
    
    async def ingest_market_movements(self):
        """Ingest real-time market and industry data"""
        # Check for fashion/luxury market updates
        market_data = self.redis_client.hgetall('market_updates')
        
        for key, value in market_data.items():
            try:
                data = json.loads(value)
                
                update = IntelligenceUpdate(
                    source='market_data',
                    data=data,
                    confidence=0.8,
                    timestamp=datetime.now(),
                    impact_score=data.get('market_impact', 0.5)
                )
                
                await self.learning_queue.put(update)
                
            except Exception as e:
                self.logger.error(f"Error processing market data: {e}")
    
    async def model_update_loop(self):
        """Process learning updates and update models in real-time"""
        accumulated_updates = []
        
        while True:
            try:
                # Collect updates for batch processing
                timeout = 10  # Process every 10 seconds
                
                try:
                    update = await asyncio.wait_for(self.learning_queue.get(), timeout=timeout)
                    accumulated_updates.append(update)
                except asyncio.TimeoutError:
                    pass
                
                # Process accumulated updates
                if accumulated_updates:
                    await self.process_learning_batch(accumulated_updates)
                    accumulated_updates.clear()
                
            except Exception as e:
                self.logger.error(f"Model update error: {e}")
                await asyncio.sleep(30)
    
    async def process_learning_batch(self, updates: List[IntelligenceUpdate]):
        """Process a batch of learning updates"""
        self.logger.info(f"🎯 Processing {len(updates)} learning updates...")
        
        # Separate updates by type and importance
        chris_updates = [u for u in updates if u.source == 'chris_feedback']
        market_updates = [u for u in updates if u.source == 'market_data']
        outcome_updates = [u for u in updates if u.source == 'investment_outcome']
        
        # Process Chris updates first (highest priority)
        if chris_updates:
            await self.update_chris_taste_model(chris_updates)
        
        # Update market understanding
        if market_updates:
            await self.update_market_model(market_updates)
        
        # Update success prediction model
        if outcome_updates:
            await self.update_outcome_model(outcome_updates)
        
        # Store processed updates for analysis
        self.store_learning_history(updates)
    
    async def update_chris_taste_model(self, updates: List[IntelligenceUpdate]):
        """Update Chris Burch's taste model with new data"""
        self.logger.info(f"💎 Updating Chris taste model with {len(updates)} data points")
        
        # Calculate model adjustments
        taste_adjustments = {}
        
        for update in updates:
            data = update.data
            
            if data.get('type') == 'brand_rating':
                # Chris rated a brand
                brand_id = data['brand_id']
                rating = data['rating']
                features = data['features']
                
                # Update taste vector
                taste_adjustments[brand_id] = {
                    'rating_delta': rating - data.get('previous_rating', 0.5),
                    'feature_weights': features,
                    'confidence': update.confidence,
                    'timestamp': update.timestamp.isoformat()
                }
            
            elif data.get('type') == 'investment_decision':
                # Chris made an investment decision
                decision = data['decision']  # 'invest', 'pass', 'exit'
                brand_features = data['brand_features']
                
                # Adjust model based on decision
                weight_multiplier = 1.5 if decision == 'invest' else -0.5
                
                for feature, value in brand_features.items():
                    if feature not in taste_adjustments:
                        taste_adjustments[feature] = 0
                    taste_adjustments[feature] += value * weight_multiplier * update.impact_score
        
        # Apply adjustments to model
        await self.apply_taste_adjustments(taste_adjustments)
    
    async def apply_taste_adjustments(self, adjustments: Dict):
        """Apply taste model adjustments"""
        # Store current model state
        current_model = self.redis_client.hgetall('chris_taste_model')
        
        # Apply incremental updates
        for feature, adjustment in adjustments.items():
            current_value = float(current_model.get(feature, 0.5))
            
            if isinstance(adjustment, dict):
                # Complex adjustment
                delta = adjustment['rating_delta'] * self.learning_rate
                new_value = current_value + delta
            else:
                # Simple adjustment
                delta = adjustment * self.learning_rate
                new_value = current_value + delta
            
            # Clamp values
            new_value = max(0.0, min(1.0, new_value))
            
            # Update Redis
            self.redis_client.hset('chris_taste_model', feature, str(new_value))
        
        # Update model version
        version = int(self.redis_client.get('model_version') or 0) + 1
        self.redis_client.set('model_version', version)
        
        self.logger.info(f"🔄 Updated taste model to version {version}")
    
    def store_learning_history(self, updates: List[IntelligenceUpdate]):
        """Store learning history for analysis"""
        history_data = {
            'timestamp': datetime.now().isoformat(),
            'update_count': len(updates),
            'sources': [u.source for u in updates],
            'total_impact': sum(u.impact_score for u in updates),
            'avg_confidence': np.mean([u.confidence for u in updates])
        }
        
        self.redis_client.lpush('learning_history', json.dumps(history_data))
        
        # Keep only last 1000 entries
        self.redis_client.ltrim('learning_history', 0, 999)

# Global engine instance
learning_engine = ContinuousLearningEngine()

if __name__ == "__main__":
    asyncio.run(learning_engine.start_continuous_learning())
