import json
import numpy as np

# Load visual analysis results
try:
    with open('production_data/visual_analysis_fast.json', 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    print("No visual analysis data found")
    exit(1)

print(f"📊 Analyzing patterns from {len(data)} companies...")

# Extract visual characteristics
brightness_values = []
saturation_values = []
complexity_values = []

for company, analysis in data.items():
    visual = analysis.get('visual_analysis', {})
    if visual:
        brightness_values.append(visual.get('average_brightness', 0))
        saturation_values.append(visual.get('average_saturation', 0))
        complexity_values.append(visual.get('visual_complexity', 0))

if brightness_values:
    chris_preferences = {
        'discovered_from_companies': list(data.keys()),
        'total_companies_analyzed': len(data),
        'brightness_preference': {
            'average': float(np.mean(brightness_values)),
            'range': [float(np.min(brightness_values)), float(np.max(brightness_values))],
            'std': float(np.std(brightness_values))
        },
        'saturation_preference': {
            'average': float(np.mean(saturation_values)),
            'range': [float(np.min(saturation_values)), float(np.max(saturation_values))],
            'std': float(np.std(saturation_values))
        },
        'complexity_preference': {
            'average': float(np.mean(complexity_values)),
            'range': [float(np.min(complexity_values)), float(np.max(complexity_values))],
            'preference_type': 'minimalist' if np.mean(complexity_values) < 0.5 else 'complex'
        }
    }
    
    # Save discovered preferences
    with open('production_data/chris_burch_preferences.json', 'w') as f:
        json.dump(chris_preferences, f, indent=2)
    
    print("🎯 CHRIS BURCH PREFERENCES DISCOVERED:")
    print("=====================================")
    print(f"📊 Based on {len(data)} portfolio companies")
    print(f"🎨 Brightness preference: {chris_preferences['brightness_preference']['average']:.1f}/255")
    print(f"🌈 Saturation preference: {chris_preferences['saturation_preference']['average']:.1f}/255")
    print(f"🎪 Style preference: {chris_preferences['complexity_preference']['preference_type']}")
    print(f"📈 Complexity score: {chris_preferences['complexity_preference']['average']:.3f}")

else:
    print("❌ No valid visual data to analyze")
