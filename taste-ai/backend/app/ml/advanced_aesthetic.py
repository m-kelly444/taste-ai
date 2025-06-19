import torch
import torch.nn as nn
import numpy as np
from PIL import Image, ImageFilter, ImageStat
import cv2
from typing import Dict, List, Tuple, Optional
import math
import random
from dataclasses import dataclass
from enum import Enum

class AestheticDimension(Enum):
    COLOR_HARMONY = "color_harmony"
    COMPOSITION = "composition"
    VISUAL_BALANCE = "visual_balance"
    COMPLEXITY = "complexity"
    EMOTIONAL_IMPACT = "emotional_impact"
    COMMERCIAL_APPEAL = "commercial_appeal"

@dataclass
class BurchPreferences:
    """Chris Burch's known aesthetic preferences"""
    preferred_colors = {
        'navy': 0.95, 'camel': 0.92, 'cream': 0.90, 'sage': 0.88,
        'charcoal': 0.85, 'burgundy': 0.83, 'gold': 0.80, 'silver': 0.78
    }
    
    preferred_styles = {
        'minimalist': 0.95, 'classic': 0.93, 'sophisticated': 0.90,
        'timeless': 0.88, 'elegant': 0.85, 'contemporary': 0.82
    }
    
    brand_aesthetics = {
        'tory_burch': 0.98, 'luxury_basics': 0.95, 'americana': 0.90,
        'preppy_chic': 0.88, 'bohemian_luxury': 0.85
    }

class AdvancedColorAnalyzer:
    """Advanced color analysis for aesthetic scoring"""
    
    def __init__(self):
        self.golden_ratios = [1.618, 0.618, 2.618]
        self.harmonic_ratios = [1.5, 2.0, 3.0, 4.0]
    
    def analyze_color_harmony(self, image: Image.Image) -> Dict[str, float]:
        """Analyze color harmony using advanced color theory"""
        img_array = np.array(image.convert('RGB'))
        
        # Convert to HSV for better color analysis
        hsv = cv2.cvtColor(img_array, cv2.COLOR_RGB2HSV)
        
        # Extract dominant colors using k-means clustering
        pixels = img_array.reshape(-1, 3)
        
        # Simplified k-means (in production, use sklearn)
        dominant_colors = self._extract_dominant_colors(pixels, k=5)
        
        # Analyze color relationships
        harmony_score = self._calculate_color_harmony(dominant_colors)
        temperature = self._calculate_color_temperature(dominant_colors)
        saturation = self._calculate_saturation_balance(hsv)
        
        return {
            'harmony_score': harmony_score,
            'color_temperature': temperature,
            'saturation_balance': saturation,
            'dominant_colors': dominant_colors.tolist(),
            'burch_color_alignment': self._burch_color_score(dominant_colors)
        }
    
    def _extract_dominant_colors(self, pixels: np.ndarray, k: int = 5) -> np.ndarray:
        """Extract dominant colors using simplified clustering"""
        # Simplified version - in production use proper k-means
        unique_colors = np.unique(pixels.reshape(-1, pixels.shape[-1]), axis=0)
        if len(unique_colors) > k:
            # Sample k colors based on frequency
            indices = np.random.choice(len(unique_colors), k, replace=False)
            return unique_colors[indices]
        return unique_colors
    
    def _calculate_color_harmony(self, colors: np.ndarray) -> float:
        """Calculate color harmony score"""
        if len(colors) < 2:
            return 0.5
        
        harmony_score = 0.0
        count = 0
        
        for i in range(len(colors)):
            for j in range(i + 1, len(colors)):
                # Convert to HSV for hue analysis
                hsv1 = self._rgb_to_hsv(colors[i])
                hsv2 = self._rgb_to_hsv(colors[j])
                
                # Calculate hue difference
                hue_diff = abs(hsv1[0] - hsv2[0])
                hue_diff = min(hue_diff, 360 - hue_diff)  # Circular distance
                
                # Score based on harmonic relationships
                if hue_diff in [0, 30, 60, 90, 120, 180]:  # Harmonic intervals
                    harmony_score += 1.0
                elif hue_diff < 15 or abs(hue_diff - 180) < 15:  # Complementary
                    harmony_score += 0.8
                else:
                    harmony_score += 0.3
                
                count += 1
        
        return harmony_score / count if count > 0 else 0.5
    
    def _rgb_to_hsv(self, rgb: np.ndarray) -> Tuple[float, float, float]:
        """Convert RGB to HSV"""
        r, g, b = rgb / 255.0
        max_val = max(r, g, b)
        min_val = min(r, g, b)
        diff = max_val - min_val
        
        # Hue
        if diff == 0:
            h = 0
        elif max_val == r:
            h = (60 * ((g - b) / diff) + 360) % 360
        elif max_val == g:
            h = (60 * ((b - r) / diff) + 120) % 360
        else:
            h = (60 * ((r - g) / diff) + 240) % 360
        
        # Saturation
        s = 0 if max_val == 0 else diff / max_val
        
        # Value
        v = max_val
        
        return h, s, v
    
    def _calculate_color_temperature(self, colors: np.ndarray) -> float:
        """Calculate overall color temperature (warm vs cool)"""
        total_temp = 0.0
        for color in colors:
            r, g, b = color
            # Simplified temperature calculation
            temp = (r + g * 0.5) / (b + 1)  # Warm colors have higher values
            total_temp += temp
        
        return min(total_temp / len(colors) / 2.0, 1.0)  # Normalize to 0-1
    
    def _calculate_saturation_balance(self, hsv: np.ndarray) -> float:
        """Calculate saturation balance"""
        saturation = hsv[:, :, 1].flatten() / 255.0
        return 1.0 - np.std(saturation)  # Lower std = better balance
    
    def _burch_color_score(self, colors: np.ndarray) -> float:
        """Score based on Chris Burch's color preferences"""
        burch_prefs = BurchPreferences()
        
        # Convert colors to nearest named colors (simplified)
        color_names = []
        for color in colors:
            name = self._color_to_name(color)
            color_names.append(name)
        
        # Score based on Burch preferences
        total_score = 0.0
        for name in color_names:
            total_score += burch_prefs.preferred_colors.get(name, 0.5)
        
        return total_score / len(color_names) if color_names else 0.5
    
    def _color_to_name(self, rgb: np.ndarray) -> str:
        """Convert RGB to color name (simplified)"""
        r, g, b = rgb
        
        # Simplified color naming
        if r > 200 and g > 200 and b > 200:
            return 'cream'
        elif r < 50 and g < 50 and b > 100:
            return 'navy'
        elif r > 150 and g > 100 and b < 80:
            return 'camel'
        elif r < 80 and g < 80 and b < 80:
            return 'charcoal'
        else:
            return 'neutral'

class CompositionAnalyzer:
    """Advanced composition analysis"""
    
    def analyze_composition(self, image: Image.Image) -> Dict[str, float]:
        """Analyze image composition using advanced techniques"""
        img_array = np.array(image.convert('L'))  # Grayscale for composition
        
        # Rule of thirds analysis
        rule_of_thirds = self._analyze_rule_of_thirds(img_array)
        
        # Visual weight distribution
        weight_balance = self._analyze_visual_weight(img_array)
        
        # Leading lines detection
        leading_lines = self._detect_leading_lines(img_array)
        
        # Symmetry analysis
        symmetry = self._analyze_symmetry(img_array)
        
        # Depth analysis
        depth_score = self._analyze_depth(img_array)
        
        return {
            'rule_of_thirds': rule_of_thirds,
            'visual_balance': weight_balance,
            'leading_lines': leading_lines,
            'symmetry': symmetry,
            'depth_perception': depth_score,
            'overall_composition': (rule_of_thirds + weight_balance + symmetry) / 3
        }
    
    def _analyze_rule_of_thirds(self, img: np.ndarray) -> float:
        """Analyze adherence to rule of thirds"""
        h, w = img.shape
        
        # Define third lines
        third_h = h // 3
        third_w = w // 3
        
        # Check for interesting content at intersection points
        intersections = [
            (third_w, third_h), (2 * third_w, third_h),
            (third_w, 2 * third_h), (2 * third_w, 2 * third_h)
        ]
        
        score = 0.0
        for x, y in intersections:
            if 0 <= x < w and 0 <= y < h:
                # Check local variance (indicates interesting content)
                local_region = img[max(0, y-10):min(h, y+10), max(0, x-10):min(w, x+10)]
                variance = np.var(local_region)
                score += min(variance / 1000.0, 1.0)  # Normalize
        
        return score / len(intersections)
    
    def _analyze_visual_weight(self, img: np.ndarray) -> float:
        """Analyze visual weight distribution"""
        h, w = img.shape
        
        # Divide image into quadrants
        mid_h, mid_w = h // 2, w // 2
        
        quadrants = [
            img[:mid_h, :mid_w],      # Top-left
            img[:mid_h, mid_w:],      # Top-right
            img[mid_h:, :mid_w],      # Bottom-left
            img[mid_h:, mid_w:]       # Bottom-right
        ]
        
        # Calculate visual weight (brightness + variance)
        weights = []
        for quad in quadrants:
            brightness = np.mean(quad)
            variance = np.var(quad)
            weight = brightness + variance / 100.0
            weights.append(weight)
        
        # Balance score (lower std = better balance)
        balance = 1.0 - (np.std(weights) / np.mean(weights))
        return max(0.0, balance)
    
    def _detect_leading_lines(self, img: np.ndarray) -> float:
        """Detect leading lines in composition"""
        # Simplified edge detection
        edges = cv2.Canny(img, 50, 150) if 'cv2' in globals() else np.zeros_like(img)
        
        # Count edge pixels as proxy for leading lines
        edge_density = np.sum(edges > 0) / (img.shape[0] * img.shape[1])
        
        # Optimal range for leading lines
        if 0.05 <= edge_density <= 0.15:
            return 1.0
        elif edge_density < 0.05:
            return edge_density / 0.05
        else:
            return max(0.0, 1.0 - (edge_density - 0.15) / 0.1)
    
    def _analyze_symmetry(self, img: np.ndarray) -> float:
        """Analyze image symmetry"""
        h, w = img.shape
        
        # Vertical symmetry
        left_half = img[:, :w//2]
        right_half = np.fliplr(img[:, w//2:])
        
        # Resize to match if needed
        min_w = min(left_half.shape[1], right_half.shape[1])
        left_half = left_half[:, :min_w]
        right_half = right_half[:, :min_w]
        
        # Calculate similarity
        diff = np.abs(left_half.astype(float) - right_half.astype(float))
        symmetry_score = 1.0 - (np.mean(diff) / 255.0)
        
        return max(0.0, symmetry_score)
    
    def _analyze_depth(self, img: np.ndarray) -> float:
        """Analyze depth perception in image"""
        # Simplified depth analysis using blur gradient
        blurred = cv2.GaussianBlur(img, (15, 15), 0) if 'cv2' in globals() else img
        
        # Calculate local variance to detect depth cues
        variance_map = np.zeros_like(img, dtype=float)
        kernel_size = 5
        
        for i in range(kernel_size, img.shape[0] - kernel_size):
            for j in range(kernel_size, img.shape[1] - kernel_size):
                local_region = img[i-kernel_size:i+kernel_size, j-kernel_size:j+kernel_size]
                variance_map[i, j] = np.var(local_region)
        
        # Depth score based on variance distribution
        depth_score = np.std(variance_map) / np.mean(variance_map) if np.mean(variance_map) > 0 else 0
        
        return min(depth_score / 10.0, 1.0)  # Normalize

class AdvancedAestheticEngine:
    """Advanced aesthetic analysis engine"""
    
    def __init__(self):
        self.color_analyzer = AdvancedColorAnalyzer()
        self.composition_analyzer = CompositionAnalyzer()
        self.burch_preferences = BurchPreferences()
    
    def analyze_comprehensive(self, image: Image.Image) -> Dict:
        """Comprehensive aesthetic analysis"""
        
        # Ensure RGB mode
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Run all analyses
        color_analysis = self.color_analyzer.analyze_color_harmony(image)
        composition_analysis = self.composition_analyzer.analyze_composition(image)
        
        # Calculate individual dimension scores
        scores = {
            AestheticDimension.COLOR_HARMONY.value: color_analysis['harmony_score'],
            AestheticDimension.COMPOSITION.value: composition_analysis['overall_composition'],
            AestheticDimension.VISUAL_BALANCE.value: composition_analysis['visual_balance'],
            AestheticDimension.COMPLEXITY.value: self._calculate_complexity(image),
            AestheticDimension.EMOTIONAL_IMPACT.value: self._calculate_emotional_impact(color_analysis, composition_analysis),
            AestheticDimension.COMMERCIAL_APPEAL.value: self._calculate_commercial_appeal(color_analysis, composition_analysis)
        }
        
        # Calculate overall aesthetic score
        overall_score = self._calculate_weighted_score(scores)
        
        # Chris Burch specific analysis
        burch_analysis = self._burch_specific_analysis(color_analysis, composition_analysis, scores)
        
        # Trend prediction
        trend_analysis = self._predict_trends(scores, color_analysis)
        
        # Generate insights
        insights = self._generate_insights(scores, color_analysis, composition_analysis)
        
        return {
            'aesthetic_score': overall_score,
            'dimension_scores': scores,
            'color_analysis': color_analysis,
            'composition_analysis': composition_analysis,
            'burch_analysis': burch_analysis,
            'trend_analysis': trend_analysis,
            'insights': insights,
            'confidence': self._calculate_confidence(scores),
            'metadata': {
                'model_version': 'advanced_v2.0',
                'analysis_timestamp': '2025-06-19T12:00:00Z',
                'image_size': image.size,
                'color_mode': image.mode
            }
        }
    
    def _calculate_complexity(self, image: Image.Image) -> float:
        """Calculate visual complexity"""
        # Convert to grayscale
        gray = image.convert('L')
        img_array = np.array(gray)
        
        # Calculate edge density
        edges = cv2.Canny(img_array, 50, 150) if 'cv2' in globals() else np.zeros_like(img_array)
        edge_density = np.sum(edges > 0) / (img_array.shape[0] * img_array.shape[1])
        
        # Calculate color variance
        rgb_array = np.array(image)
        color_variance = np.var(rgb_array)
        
        # Combine metrics
        complexity = (edge_density * 10 + color_variance / 10000) / 2
        return min(complexity, 1.0)
    
    def _calculate_emotional_impact(self, color_analysis: Dict, composition_analysis: Dict) -> float:
        """Calculate emotional impact score"""
        # Factors that increase emotional impact
        factors = [
            color_analysis['saturation_balance'],
            composition_analysis['depth_perception'],
            color_analysis['color_temperature'],  # Warm colors = higher impact
            composition_analysis['leading_lines']
        ]
        
        return np.mean(factors)
    
    def _calculate_commercial_appeal(self, color_analysis: Dict, composition_analysis: Dict) -> float:
        """Calculate commercial appeal"""
        # Factors for commercial success
        factors = [
            color_analysis['burch_color_alignment'],
            composition_analysis['visual_balance'],
            composition_analysis['rule_of_thirds'],
            (1.0 - abs(color_analysis['color_temperature'] - 0.6))  # Slightly warm
        ]
        
        return np.mean(factors)
    
    def _calculate_weighted_score(self, scores: Dict[str, float]) -> float:
        """Calculate weighted overall aesthetic score"""
        weights = {
            AestheticDimension.COLOR_HARMONY.value: 0.25,
            AestheticDimension.COMPOSITION.value: 0.25,
            AestheticDimension.VISUAL_BALANCE.value: 0.15,
            AestheticDimension.COMPLEXITY.value: 0.10,
            AestheticDimension.EMOTIONAL_IMPACT.value: 0.15,
            AestheticDimension.COMMERCIAL_APPEAL.value: 0.10
        }
        
        weighted_sum = sum(scores[dim] * weights[dim] for dim in scores)
        return weighted_sum
    
    def _burch_specific_analysis(self, color_analysis: Dict, composition_analysis: Dict, scores: Dict) -> Dict:
        """Chris Burch specific aesthetic analysis"""
        
        # Burch preference alignment
        burch_score = (
            color_analysis['burch_color_alignment'] * 0.4 +
            scores[AestheticDimension.COMMERCIAL_APPEAL.value] * 0.3 +
            composition_analysis['visual_balance'] * 0.3
        )
        
        # Style classification
        style_scores = {
            'tory_burch_signature': burch_score * 0.9,
            'luxury_minimalist': scores[AestheticDimension.COMPOSITION.value] * 0.8,
            'americana_chic': color_analysis['color_temperature'] * 0.7,
            'sophisticated_casual': scores[AestheticDimension.VISUAL_BALANCE.value] * 0.8
        }
        
        # Investment recommendation
        investment_score = (burch_score + scores[AestheticDimension.COMMERCIAL_APPEAL.value]) / 2
        
        recommendation = "STRONG BUY" if investment_score > 0.8 else \
                        "BUY" if investment_score > 0.6 else \
                        "HOLD" if investment_score > 0.4 else "AVOID"
        
        return {
            'burch_alignment_score': burch_score,
            'style_classification': style_scores,
            'investment_recommendation': recommendation,
            'investment_score': investment_score,
            'brand_fit': self._assess_brand_fit(color_analysis, composition_analysis),
            'market_timing': self._assess_market_timing(scores)
        }
    
    def _predict_trends(self, scores: Dict, color_analysis: Dict) -> Dict:
        """Predict trend potential"""
        
        # Trend factors
        viral_potential = (
            scores[AestheticDimension.EMOTIONAL_IMPACT.value] * 0.4 +
            scores[AestheticDimension.COMPLEXITY.value] * 0.3 +
            color_analysis['saturation_balance'] * 0.3
        )
        
        longevity = (
            scores[AestheticDimension.COMPOSITION.value] * 0.4 +
            scores[AestheticDimension.COLOR_HARMONY.value] * 0.4 +
            scores[AestheticDimension.VISUAL_BALANCE.value] * 0.2
        )
        
        market_appeal = scores[AestheticDimension.COMMERCIAL_APPEAL.value]
        
        # Trend timeline prediction
        timeline = "3-6 months" if viral_potential > 0.8 else \
                  "6-12 months" if viral_potential > 0.6 else \
                  "12+ months"
        
        return {
            'viral_potential': viral_potential,
            'longevity_score': longevity,
            'market_appeal': market_appeal,
            'trend_timeline': timeline,
            'social_media_score': viral_potential * 1.2,  # Amplified for social
            'influence_potential': (viral_potential + market_appeal) / 2
        }
    
    def _generate_insights(self, scores: Dict, color_analysis: Dict, composition_analysis: Dict) -> List[str]:
        """Generate actionable insights"""
        insights = []
        
        # Color insights
        if color_analysis['harmony_score'] > 0.8:
            insights.append("Excellent color harmony creates visual cohesion")
        elif color_analysis['harmony_score'] < 0.4:
            insights.append("Consider adjusting color palette for better harmony")
        
        # Composition insights
        if composition_analysis['rule_of_thirds'] > 0.7:
            insights.append("Strong compositional structure follows design principles")
        
        if composition_analysis['visual_balance'] < 0.5:
            insights.append("Rebalancing visual elements could improve impact")
        
        # Burch-specific insights
        if color_analysis['burch_color_alignment'] > 0.8:
            insights.append("Color palette aligns perfectly with Burch aesthetic")
        
        # Commercial insights
        if scores[AestheticDimension.COMMERCIAL_APPEAL.value] > 0.7:
            insights.append("High commercial potential for fashion market")
        
        return insights
    
    def _calculate_confidence(self, scores: Dict) -> float:
        """Calculate confidence in the analysis"""
        # Higher confidence when scores are not too extreme
        variance = np.var(list(scores.values()))
        confidence = 1.0 - min(variance * 2, 0.3)  # Cap reduction at 30%
        return confidence
    
    def _assess_brand_fit(self, color_analysis: Dict, composition_analysis: Dict) -> Dict:
        """Assess fit with various fashion brands"""
        return {
            'tory_burch': color_analysis['burch_color_alignment'],
            'luxury_contemporary': composition_analysis['visual_balance'],
            'mass_market': scores[AestheticDimension.COMMERCIAL_APPEAL.value] * 0.8,
            'high_fashion': scores[AestheticDimension.EMOTIONAL_IMPACT.value]
        }
    
    def _assess_market_timing(self, scores: Dict) -> str:
        """Assess optimal market timing"""
        overall = np.mean(list(scores.values()))
        
        if overall > 0.8:
            return "LAUNCH NOW - Market conditions optimal"
        elif overall > 0.6:
            return "LAUNCH SOON - Strong potential with minor adjustments"
        elif overall > 0.4:
            return "DEVELOP FURTHER - Needs refinement before launch"
        else:
            return "RECONSIDER - Significant changes needed"

# Global advanced engine instance
advanced_engine = AdvancedAestheticEngine()
