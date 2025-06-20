#!/usr/bin/env python3
"""
PRODUCTION Keyword Performance Optimizer
Continuously optimizes keyword selection based on real performance data
"""

import asyncio
import redis
import json
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Tuple
import logging

class ProductionKeywordOptimizer:
    def __init__(self):
        self.redis_client = redis.Redis(host='localhost', port=6381, db=1)
        self.optimization_cycles = 0
        self.performance_window = timedelta(hours=24)
        
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    async def execute_continuous_optimization(self):
        """Execute continuous keyword optimization"""
        while True:
            try:
                self.optimization_cycles += 1
                self.logger.info(f"⚡ OPTIMIZATION CYCLE {self.optimization_cycles}")
                
                # Get all tracked keywords
                all_keywords = self.redis_client.smembers('all_keywords')
                
                if not all_keywords:
                    self.logger.info("No keywords to optimize yet")
                    await asyncio.sleep(3600)
                    continue
                
                # Analyze performance of each keyword
                keyword_scores = await self.analyze_keyword_performance(all_keywords)
                
                # Optimize keyword selection
                optimized_keywords = await self.optimize_keyword_selection(keyword_scores)
                
                # Update active keyword set
                await self.update_active_keywords(optimized_keywords)
                
                # Generate optimization report
                await self.generate_optimization_report(keyword_scores, optimized_keywords)
                
                await asyncio.sleep(3600)  # Optimize every hour
                
            except Exception as e:
                self.logger.error(f"Optimization error: {e}")
                await asyncio.sleep(1800)
    
    async def analyze_keyword_performance(self, keywords):
        """Analyze performance of all keywords"""
        keyword_scores = {}
        
        for keyword_bytes in keywords:
            keyword = keyword_bytes.decode('utf-8')
            score = await self.calculate_keyword_score(keyword)
            keyword_scores[keyword] = score
        
        return keyword_scores
    
    async def calculate_keyword_score(self, keyword):
        """Calculate comprehensive performance score for keyword"""
        keyword_key = f"keyword_performance:{hashlib.md5(keyword.encode()).hexdigest()}"
        
        performance_data = self.redis_client.get(keyword_key)
        if not performance_data:
            return 0.0
        
        data = json.loads(performance_data)
        
        # Multi-factor scoring
        usage_score = min(data.get('usage_count', 0) / 100.0, 1.0)  # Normalize usage
        success_rate = data.get('success_rate', 0.0)
        recency_score = self.calculate_recency_score(data.get('last_seen'))
        source_score = self.calculate_source_score(data.get('source', ''))
        
        # Weighted combination
        total_score = (
            usage_score * 0.3 +
            success_rate * 0.4 +
            recency_score * 0.2 +
            source_score * 0.1
        )
        
        return total_score
    
    def calculate_recency_score(self, last_seen_str):
        """Calculate score based on how recently keyword was seen"""
        if not last_seen_str:
            return 0.0
        
        try:
            last_seen = datetime.fromisoformat(last_seen_str.replace('Z', '+00:00'))
            time_diff = datetime.now() - last_seen.replace(tzinfo=None)
            
            # Score decreases with time
            if time_diff < timedelta(hours=1):
                return 1.0
            elif time_diff < timedelta(hours=24):
                return 0.8
            elif time_diff < timedelta(days=7):
                return 0.5
            else:
                return 0.1
        except:
            return 0.0
    
    def calculate_source_score(self, source):
        """Calculate score based on keyword source quality"""
        source_weights = {
            'chris_feedback': 1.0,
            'investment_outcome': 0.9,
            'brand_analysis': 0.8,
            'trend_mining': 0.7,
            'competitor_analysis': 0.6,
            'social_media': 0.5
        }
        
        for source_type, weight in source_weights.items():
            if source_type in source:
                return weight
        
        return 0.3  # Default for unknown sources
    
    async def optimize_keyword_selection(self, keyword_scores):
        """Select optimal keywords based on performance scores"""
        # Sort by score
        sorted_keywords = sorted(keyword_scores.items(), key=lambda x: x[1], reverse=True)
        
        # Select top performers (top 80%) and some exploratory keywords (bottom 20%)
        total_keywords = len(sorted_keywords)
        top_80_percent = int(total_keywords * 0.8)
        
        optimized_keywords = []
        
        # Add top performers
        optimized_keywords.extend([kw for kw, score in sorted_keywords[:top_80_percent]])
        
        # Add some exploratory keywords
        if total_keywords > top_80_percent:
            exploratory_count = min(100, total_keywords - top_80_percent)
            exploratory_keywords = [kw for kw, score in sorted_keywords[top_80_percent:top_80_percent + exploratory_count]]
            optimized_keywords.extend(exploratory_keywords)
        
        return optimized_keywords
    
    async def update_active_keywords(self, optimized_keywords):
        """Update the active keyword set"""
        # Clear current active keywords
        self.redis_client.delete('active_keywords')
        
        # Add optimized keywords
        if optimized_keywords:
            self.redis_client.sadd('active_keywords', *optimized_keywords)
        
        self.logger.info(f"✅ Updated active keywords: {len(optimized_keywords)} keywords")
    
    async def generate_optimization_report(self, keyword_scores, optimized_keywords):
        """Generate optimization performance report"""
        report = {
            'optimization_cycle': self.optimization_cycles,
            'timestamp': datetime.now().isoformat(),
            'total_keywords_analyzed': len(keyword_scores),
            'active_keywords_selected': len(optimized_keywords),
            'top_performing_keywords': sorted(keyword_scores.items(), key=lambda x: x[1], reverse=True)[:10],
            'optimization_stats': {
                'avg_keyword_score': np.mean(list(keyword_scores.values())),
                'max_keyword_score': max(keyword_scores.values()) if keyword_scores else 0,
                'min_keyword_score': min(keyword_scores.values()) if keyword_scores else 0
            }
        }
        
        # Store report
        report_key = f"optimization_report:{self.optimization_cycles}"
        self.redis_client.set(report_key, json.dumps(report))
        self.redis_client.expire(report_key, 604800)  # Keep for 1 week
        
        self.logger.info(f"📊 Optimization report generated: {report['optimization_stats']}")

# Global optimizer
production_optimizer = ProductionKeywordOptimizer()

if __name__ == "__main__":
    import hashlib
    asyncio.run(production_optimizer.execute_continuous_optimization())
