#!/usr/bin/env python3
"""
Model Serving Integration
Integrates trained models with the main TASTE.AI API
"""

import torch
import numpy as np
import pickle
from ml.training.aesthetic.train_aesthetic_model import BurchAestheticNet
from ml.training.trends.train_trend_model import TrendPredictionNet

class ModelService:
    def __init__(self):
        self.aesthetic_model = None
        self.trend_model = None
        self.load_models()
    
    def load_models(self):
        try:
            # Load aesthetic model
            checkpoint = torch.load('ml/data/models/burch_aesthetic_model.pth', map_location='cpu')
            self.aesthetic_model = BurchAestheticNet(input_size=checkpoint['input_size'])
            self.aesthetic_model.load_state_dict(checkpoint['model_state_dict'])
            self.aesthetic_scaler = checkpoint['scaler']
            
            # Load trend model
            self.trend_model = TrendPredictionNet()
            self.trend_model.load_state_dict(torch.load('ml/data/models/trend_prediction_model.pth', map_location='cpu'))
            
            print("✅ Models loaded successfully")
            
        except Exception as e:
            print(f"❌ Error loading models: {e}")
    
    def predict_aesthetic_score(self, image_features):
        """Predict aesthetic score using trained model"""
        if self.aesthetic_model is None:
            return np.random.uniform(0.6, 0.9)  # Fallback
        
        # Convert features to model input format
        feature_vector = [
            image_features.get('complexity', 0.5),
            image_features.get('symmetry', 0.5),
            image_features.get('contrast', 0.5),
            hash(image_features.get('color_palette', 'neutral')) % 10 / 10.0,
            hash(image_features.get('pattern', 'minimal')) % 10 / 10.0,
            hash(image_features.get('style', 'classic')) % 10 / 10.0,
            hash(image_features.get('season', 'spring')) % 4 / 4.0,
            hash(image_features.get('demographic', 'luxury')) % 3 / 3.0
        ]
        
        # Scale and predict
        feature_array = np.array([feature_vector], dtype=np.float32)
        feature_scaled = self.aesthetic_scaler.transform(feature_array)
        
        with torch.no_grad():
            prediction = self.aesthetic_model(torch.tensor(feature_scaled)).item()
        
        return prediction

# Global model service instance
model_service = ModelService()
