from PIL import Image
import numpy as np
from typing import Dict, List
import random

class TasteScorer:
    def __init__(self):
        self.burch_preferences = {
            "color_weights": {"neutral": 0.8, "earth": 0.7, "bright": 0.3},
            "pattern_weights": {"geometric": 0.6, "organic": 0.8, "minimal": 0.9},
            "composition_weights": {"symmetry": 0.7, "balance": 0.9, "contrast": 0.6}
        }
    
    def analyze_trends(self, image: Image.Image) -> Dict:
        return {
            "trend_score": round(random.uniform(0.6, 0.9), 2),
            "viral_potential": round(random.uniform(0.5, 0.8), 2),
            "market_appeal": round(random.uniform(0.7, 0.95), 2),
            "seasonal_relevance": round(random.uniform(0.6, 0.85), 2)
        }
    
    def score_burch_taste(self, image: Image.Image) -> Dict:
        base_score = random.uniform(0.6, 0.9)
        
        return {
            "burch_score": round(base_score, 2),
            "confidence": round(base_score * 0.9, 2),
            "reasoning": [
                "Strong color harmony",
                "Excellent composition",
                "Market-ready aesthetic"
            ]
        }
    
    def predict_commercial_success(self, image: Image.Image) -> Dict:
        return {
            "success_probability": round(random.uniform(0.6, 0.9), 2),
            "target_demographics": ["millennials", "luxury_consumers"],
            "price_point_recommendation": "premium",
            "market_timing": "optimal"
        }
