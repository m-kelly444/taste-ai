#!/usr/bin/env python3
"""
Advanced Aesthetic Scoring Model Training
Specialized for Chris Burch's taste preferences
"""

import json
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
from datetime import datetime

class BurchAestheticDataset(Dataset):
    def __init__(self, data, scaler=None, fit_scaler=False):
        self.data = data
        
        # Extract features
        self.features = []
        self.labels = []
        
        feature_names = ['complexity', 'symmetry', 'contrast']
        categorical_features = ['color_palette', 'pattern', 'style']
        
        # Create feature vectors
        for sample in data:
            feature_vector = []
            
            # Numerical features
            for feat in feature_names:
                feature_vector.append(sample['image_features'][feat])
            
            # Encode categorical features (simple one-hot)
            for cat_feat in categorical_features:
                value = sample['image_features'][cat_feat]
                # Simple hash-based encoding for demo
                encoded = [hash(value) % 10 / 10.0]
                feature_vector.extend(encoded)
            
            # Market context features
            feature_vector.append(hash(sample['market_context']['season']) % 4 / 4.0)
            feature_vector.append(hash(sample['market_context']['target_demographic']) % 3 / 3.0)
            
            self.features.append(feature_vector)
            self.labels.append(sample['burch_score'])
        
        self.features = np.array(self.features, dtype=np.float32)
        self.labels = np.array(self.labels, dtype=np.float32)
        
        # Scale features
        if fit_scaler:
            self.scaler = StandardScaler()
            self.features = self.scaler.fit_transform(self.features)
        elif scaler:
            self.scaler = scaler
            self.features = self.scaler.transform(self.features)
    
    def __len__(self):
        return len(self.features)
    
    def __getitem__(self, idx):
        return torch.tensor(self.features[idx]), torch.tensor(self.labels[idx])

class BurchAestheticNet(nn.Module):
    def __init__(self, input_size=8):
        super(BurchAestheticNet, self).__init__()
        
        self.network = nn.Sequential(
            nn.Linear(input_size, 64),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(32, 16),
            nn.ReLU(),
            nn.Linear(16, 1),
            nn.Sigmoid()
        )
    
    def forward(self, x):
        return self.network(x).squeeze()

def train_model():
    print("🧠 Training Chris Burch Aesthetic Model...")
    
    # Load data
    with open('../../data/raw/burch_aesthetic_training.json', 'r') as f:
        data = json.load(f)
    
    # Split data
    train_data, test_data = train_test_split(data, test_size=0.2, random_state=42)
    train_data, val_data = train_test_split(train_data, test_size=0.2, random_state=42)
    
    # Create datasets
    train_dataset = BurchAestheticDataset(train_data, fit_scaler=True)
    val_dataset = BurchAestheticDataset(val_data, scaler=train_dataset.scaler)
    test_dataset = BurchAestheticDataset(test_data, scaler=train_dataset.scaler)
    
    # Create data loaders
    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False)
    
    # Initialize model
    model = BurchAestheticNet(input_size=train_dataset.features.shape[1])
    criterion = nn.MSELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    # Training loop
    train_losses = []
    val_losses = []
    
    print("Starting training...")
    
    for epoch in range(100):
        model.train()
        train_loss = 0
        
        for features, labels in train_loader:
            optimizer.zero_grad()
            outputs = model(features)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            train_loss += loss.item()
        
        # Validation
        model.eval()
        val_loss = 0
        with torch.no_grad():
            for features, labels in val_loader:
                outputs = model(features)
                loss = criterion(outputs, labels)
                val_loss += loss.item()
        
        train_loss /= len(train_loader)
        val_loss /= len(val_loader)
        
        train_losses.append(train_loss)
        val_losses.append(val_loss)
        
        if epoch % 10 == 0:
            print(f"Epoch {epoch}: Train Loss: {train_loss:.4f}, Val Loss: {val_loss:.4f}")
    
    # Save model
    torch.save({
        'model_state_dict': model.state_dict(),
        'scaler': train_dataset.scaler,
        'input_size': train_dataset.features.shape[1]
    }, '../../data/models/burch_aesthetic_model.pth')
    
    print("✅ Model training complete!")
    
    # Test set evaluation
    model.eval()
    test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)
    test_predictions = []
    test_labels = []
    
    with torch.no_grad():
        for features, labels in test_loader:
            outputs = model(features)
            test_predictions.extend(outputs.numpy())
            test_labels.extend(labels.numpy())
    
    # Calculate metrics
    mse = np.mean((np.array(test_predictions) - np.array(test_labels)) ** 2)
    mae = np.mean(np.abs(np.array(test_predictions) - np.array(test_labels)))
    correlation = np.corrcoef(test_predictions, test_labels)[0, 1]
    
    print(f"Test Results:")
    print(f"  MSE: {mse:.4f}")
    print(f"  MAE: {mae:.4f}")
    print(f"  Correlation: {correlation:.4f}")
    
    # Save training history
    history = {
        'train_losses': train_losses,
        'val_losses': val_losses,
        'test_mse': mse,
        'test_mae': mae,
        'test_correlation': correlation,
        'training_date': datetime.now().isoformat()
    }
    
    with open('../../evaluation/metrics/aesthetic_training_history.json', 'w') as f:
        json.dump(history, f, indent=2)

if __name__ == "__main__":
    train_model()
