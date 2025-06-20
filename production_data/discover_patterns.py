import json
import numpy as np

# Load results
try:
    with open('production_data/visual_analysis_results.json', 'r') as f:
        data = json.load(f)
    
    if not data:
        print("❌ No analysis data found")
        exit(1)
        
except FileNotFoundError:
    print("❌ No results file found")
    exit(1)

print(f"📊 Analyzing patterns from {len(data)} companies...")

# Extract characteristics
brightness_values = []
saturation_values = []
complexity_values = []
red_values = []
green_values = []
blue_values = []

successful_companies = []

for company, analysis in data.items():
    visual = analysis.get('visual_analysis', {})
    if visual and analysis.get('status') == 'success':
        brightness_values.append(visual.get('average_brightness', 0))
        saturation_values.append(visual.get('average_saturation', 0))
        complexity_values.append(visual.get('visual_complexity', 0))
        
        color_profile = visual.get('color_profile', {})
        red_values.append(color_profile.get('red', 0))
        green_values.append(color_profile.get('green', 0))
        blue_values.append(color_profile.get('blue', 0))
        
        successful_companies.append(company)

if not brightness_values:
    print("❌ No valid data to analyze")
    exit(1)

# Calculate Chris Burch's discovered preferences
preferences = {
    'analysis_metadata': {
        'companies_analyzed': successful_companies,
        'total_successful': len(successful_companies),
        'analysis_date': '2025-06-19'
    },
    'brightness_preferences': {
        'average': float(np.mean(brightness_values)),
        'median': float(np.median(brightness_values)),
        'range': [float(np.min(brightness_values)), float(np.max(brightness_values))],
        'standard_deviation': float(np.std(brightness_values))
    },
    'saturation_preferences': {
        'average': float(np.mean(saturation_values)),
        'median': float(np.median(saturation_values)),
        'range': [float(np.min(saturation_values)), float(np.max(saturation_values))],
        'standard_deviation': float(np.std(saturation_values))
    },
    'complexity_preferences': {
        'average': float(np.mean(complexity_values)),
        'median': float(np.median(complexity_values)),
        'preference_type': 'minimalist' if np.mean(complexity_values) < 0.5 else 'complex',
        'range': [float(np.min(complexity_values)), float(np.max(complexity_values))]
    },
    'color_preferences': {
        'red_average': float(np.mean(red_values)),
        'green_average': float(np.mean(green_values)),
        'blue_average': float(np.mean(blue_values)),
        'dominant_tone': 'warm' if np.mean(red_values) > np.mean(blue_values) else 'cool'
    }
}

# Save discovered preferences
with open('production_data/chris_burch_discovered_preferences.json', 'w') as f:
    json.dump(preferences, f, indent=2)

print("\n🎯 CHRIS BURCH AESTHETIC PREFERENCES DISCOVERED!")
print("=" * 50)
print(f"📊 Based on {len(successful_companies)} portfolio companies:")
for company in successful_companies[:10]:  # Show first 10
    print(f"   • {company}")
if len(successful_companies) > 10:
    print(f"   ... and {len(successful_companies) - 10} more")

print(f"\n🎨 DISCOVERED PREFERENCES:")
print(f"   Brightness: {preferences['brightness_preferences']['average']:.1f}/255 (prefers {'bright' if preferences['brightness_preferences']['average'] > 127 else 'darker'} aesthetics)")
print(f"   Saturation: {preferences['saturation_preferences']['average']:.1f}/255 (prefers {'vibrant' if preferences['saturation_preferences']['average'] > 127 else 'muted'} colors)")
print(f"   Complexity: {preferences['complexity_preferences']['average']:.3f} ({preferences['complexity_preferences']['preference_type']} style)")
print(f"   Color tone: {preferences['color_preferences']['dominant_tone']} tones preferred")

# Determine investment style
if preferences['brightness_preferences']['average'] > 150 and preferences['complexity_preferences']['average'] < 0.4:
    investment_style = "Clean, bright, minimalist brands"
elif preferences['saturation_preferences']['average'] > 100 and preferences['complexity_preferences']['average'] > 0.6:
    investment_style = "Bold, colorful, complex brands"
else:
    investment_style = "Balanced, sophisticated brands"

print(f"   Investment style: {investment_style}")
