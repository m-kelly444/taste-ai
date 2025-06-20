import redis, json

r = redis.Redis(host='localhost', port=6381, decode_responses=True)

# Elite Chris preferences (from analysis)
chris_elite = {
    'brightness': 180,
    'saturation': 120,
    'style': 'minimalist',
    'complexity': 0.3,
    'preferred_colors': ['navy', 'camel', 'cream', 'sage'],
    'brands': ['Tory Burch', 'BaubleBar', 'Outdoor Voices'],
    'investment_style': 'luxury_contemporary',
    'market_timing': 'contrarian_quality'
}

r.set('chris_preferences', json.dumps(chris_elite))
r.set('elite_mode', 'true')
r.set('optimization_target', 'chris_burch')

print("✅ Chris Burch elite data loaded")
