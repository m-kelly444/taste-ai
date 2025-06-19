import torch
import torch.nn as nn
from transformers import ViTModel
import numpy as np
from typing import Union
from PIL import Image
import torchvision.transforms as transforms

class AestheticVisionTransformer(nn.Module):
    def __init__(self, model_name="google/vit-base-patch16-224", num_classes=1):
        super().__init__()
        self.vit = ViTModel.from_pretrained(model_name)
        self.classifier = nn.Sequential(
            nn.Dropout(0.1),
            nn.Linear(self.vit.config.hidden_size, 512),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(512, num_classes),
            nn.Sigmoid()
        )
        
    def forward(self, pixel_values):
        outputs = self.vit(pixel_values=pixel_values)
        pooled_output = outputs.pooler_output
        return self.classifier(pooled_output)

class TrendPredictor(nn.Module):
    def __init__(self, visual_dim=768, text_dim=384, temporal_dim=64):
        super().__init__()
        
        self.visual_encoder = nn.Sequential(
            nn.Linear(visual_dim, 512),
            nn.ReLU(),
            nn.Dropout(0.1)
        )
        
        self.text_encoder = nn.Sequential(
            nn.Linear(text_dim, 256),
            nn.ReLU(),
            nn.Dropout(0.1)
        )
        
        self.temporal_encoder = nn.LSTM(
            input_size=temporal_dim,
            hidden_size=128,
            num_layers=2,
            batch_first=True,
            dropout=0.1
        )
        
        fusion_dim = 512 + 256 + 128
        self.fusion = nn.Sequential(
            nn.Linear(fusion_dim, 512),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(512, 256),
            nn.ReLU(),
            nn.Linear(256, 3)
        )
        
    def forward(self, visual_features, text_features, temporal_features):
        visual_encoded = self.visual_encoder(visual_features)
        text_encoded = self.text_encoder(text_features)
        
        temporal_output, _ = self.temporal_encoder(temporal_features)
        temporal_encoded = temporal_output[:, -1, :]
        
        fused = torch.cat([visual_encoded, text_encoded, temporal_encoded], dim=1)
        return self.fusion(fused)
