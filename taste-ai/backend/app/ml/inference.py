import torch
import numpy as np
from PIL import Image
import torchvision.transforms as transforms
from .models import AestheticVisionTransformer, TrendPredictor
from .burch_models import burch_engine
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
        
        print("✅ Aesthetic model initialized with Burch preferences")
        
    def predict(self, image: Union[Image.Image, np.ndarray]) -> float:
        """Predict aesthetic score using Burch-optimized engine"""
        if isinstance(image, np.ndarray):
            image = Image.fromarray(image)
        
        # Use the specialized Burch engine
        result = burch_engine.score_aesthetic(image)
        return result["aesthetic_score"]
    
    def predict_detailed(self, image: Union[Image.Image, np.ndarray]) -> Dict:
        """Get detailed aesthetic analysis"""
        if isinstance(image, np.ndarray):
            image = Image.fromarray(image)
        
        return burch_engine.score_aesthetic(image)
    
    def predict_batch(self, images: List[Image.Image]) -> List[float]:
        return [self.predict(img) for img in images]

class TasteEngine:
    def __init__(self):
        self.aesthetic_model = AestheticModel()
        
    def analyze_comprehensive(self, image: Image.Image) -> Dict:
        """Comprehensive analysis using Burch preferences"""
        detailed_result = self.aesthetic_model.predict_detailed(image)
        
        return {
            "aesthetic_score": detailed_result["aesthetic_score"],
            "burch_alignment": detailed_result["burch_alignment"],
            "commercial_potential": detailed_result["commercial_potential"],
            "confidence": detailed_result["confidence"],
            "analysis": detailed_result["analysis"],
            "trend_analysis": detailed_result["trend_analysis"],
            "overall_rating": self._calculate_overall_rating(detailed_result)
        }
    
    def _calculate_overall_rating(self, result: Dict) -> str:
        """Calculate overall rating based on multiple factors"""
        score = (
            result["aesthetic_score"] * 0.4 +
            result["burch_alignment"] * 0.4 +
            result["commercial_potential"] * 0.2
        )
        
        if score >= 0.9:
            return "Exceptional - Chris Burch Signature"
        elif score >= 0.8:
            return "Excellent - Strong Burch Appeal" 
        elif score >= 0.7:
            return "Good - Market Potential"
        elif score >= 0.6:
            return "Average - Needs Refinement"
        else:
            return "Below Standard - Major Issues"
