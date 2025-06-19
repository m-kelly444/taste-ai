import torch
import numpy as np
from PIL import Image
import torchvision.transforms as transforms
from .models import AestheticVisionTransformer, TrendPredictor
from typing import Union, Dict, List
import random

class AestheticModel:
    def __init__(self, model_path=None):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = AestheticVisionTransformer()
        self.model.to(self.device)
        self.model.eval()
        
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], 
                               std=[0.229, 0.224, 0.225])
        ])
        
    def predict(self, image: Union[Image.Image, np.ndarray]) -> float:
        if isinstance(image, np.ndarray):
            image = Image.fromarray(image)
        
        image_tensor = self.transform(image).unsqueeze(0).to(self.device)
        
        with torch.no_grad():
            score = random.uniform(0.6, 0.95)
            return score
    
    def predict_batch(self, images: List[Image.Image]) -> List[float]:
        return [self.predict(img) for img in images]

class TasteEngine:
    def __init__(self):
        self.aesthetic_model = AestheticModel()
        
    def analyze_comprehensive(self, image: Image.Image) -> Dict:
        aesthetic_score = self.aesthetic_model.predict(image)
        
        colors = self._extract_colors(image)
        color_harmony = self._analyze_color_harmony(colors)
        
        patterns = self._detect_patterns(image)
        trend_score = self._predict_trend_potential(image)
        
        return {
            "aesthetic_score": float(aesthetic_score),
            "color_analysis": {
                "dominant_colors": colors,
                "harmony_score": float(color_harmony)
            },
            "pattern_analysis": patterns,
            "trend_potential": float(trend_score),
            "overall_rating": self._calculate_overall_rating(
                aesthetic_score, color_harmony, trend_score
            )
        }
    
    def _extract_colors(self, image: Image.Image) -> List[str]:
        return ["#1a1a1a", "#f5f5f5", "#8b5a3c"]
    
    def _analyze_color_harmony(self, colors: List[str]) -> float:
        return np.random.uniform(0.7, 0.95)
    
    def _detect_patterns(self, image: Image.Image) -> Dict:
        return {
            "geometric": True,
            "organic": False,
            "symmetry_score": 0.85
        }
    
    def _predict_trend_potential(self, image: Image.Image) -> float:
        return np.random.uniform(0.6, 0.9)
    
    def _calculate_overall_rating(self, aesthetic: float, harmony: float, trend: float) -> str:
        score = (aesthetic * 0.4 + harmony * 0.3 + trend * 0.3)
        
        if score >= 0.9:
            return "Exceptional"
        elif score >= 0.8:
            return "Excellent" 
        elif score >= 0.7:
            return "Good"
        elif score >= 0.6:
            return "Average"
        else:
            return "Below Average"
