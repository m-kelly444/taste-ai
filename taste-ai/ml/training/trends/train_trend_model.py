#!/usr/bin/env python3
"""
Trend Prediction Model Training
Predicts trend emergence and success based on early indicators
"""

import json
import numpy as np
import torch
import torch.nn as nn
from sklearn.model_selection import train_test_split
from datetime import datetime, timedelta

class TrendPredictionNet(nn.Module):
    def __init__(self, input_size=12):
        super(TrendPredictionNet, self).__init__()
        
        self.network = nn.Sequential(
            nn.Linear(input_size, 128),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 3)  # [peak_intensity, duration, success_score]
        )
    
    def forward(self, x):
        return self.network(x)

def train_trend_model():
    print("📈 Training Trend Prediction Model...")
    
    # Load data
    with open('../../data/raw/trend_prediction_training.json', 'r') as f:
        data = json.load(f)
    
    print(f"✅ Loaded {len(data)} trend samples")
    
    # Extract features and labels
    features = []
    labels = []
    
    for trend in data:
        feature_vector = [
            trend['market_penetration'],
            trend['demographic_appeal']['age_18_25'],
            trend['demographic_appeal']['age_26_35'],
            trend['demographic_appeal']['age_36_50'],
            trend['demographic_appeal']['age_50_plus'],
            trend['channels']['social_media'],
            trend['channels']['runway'],
            trend['channels']['street_style'],
            trend['channels']['retail'],
            trend['duration_days'] / 730.0,  # Normalize to [0,1]
            hash(trend['category']) % 10 / 10.0,  # Category encoding
            trend['burch_adoption']
        ]
        
        label_vector = [
            trend['peak_intensity'],
            trend['duration_days'] / 730.0,
            trend['success_score']
        ]
        
        features.append(feature_vector)
        labels.append(label_vector)
    
    features = np.array(features, dtype=np.float32)
    labels = np.array(labels, dtype=np.float32)
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        features, labels, test_size=0.2, random_state=42
    )
    
    # Convert to tensors
    X_train = torch.tensor(X_train)
    X_test = torch.tensor(X_test)
    y_train = torch.tensor(y_train)
    y_test = torch.tensor(y_test)
    
    # Initialize model
    model = TrendPredictionNet(input_size=features.shape[1])
    criterion = nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    
    # Training
    print("Starting training...")
    for epoch in range(200):
        model.train()
        optimizer.zero_grad()
        outputs = model(X_train)
        loss = criterion(outputs, y_train)
        loss.backward()
        optimizer.step()
        
        if epoch % 20 == 0:
            model.eval()
            with torch.no_grad():
                test_outputs = model(X_test)
                test_loss = criterion(test_outputs, y_test)
            print(f"Epoch {epoch}: Train Loss: {loss.item():.4f}, Test Loss: {test_loss.item():.4f}")
    
    # Save model
    torch.save(model.state_dict(), '../../data/models/trend_prediction_model.pth')
    
    print("✅ Trend prediction model training complete!")

if __name__ == "__main__":
    train_trend_model()
