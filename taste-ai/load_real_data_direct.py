import json
import redis

try:
    # Connect to existing Redis
    redis_client = redis.Redis(host='localhost', port=6380, db=0)
    
    # Test connection
    redis_client.ping()
    print("✅ Connected to Redis")
    
    # Load the discovered Chris Burch preferences
    with open('../production_data/chris_burch_discovered_preferences.json', 'r') as f:
        preferences = json.load(f)
    
    print("🎯 Loading REAL Chris Burch preferences...")
    
    # Store the real discovered data
    redis_client.hset('chris_taste_model', 'brightness_preference', preferences['brightness_preferences']['average'])
    redis_client.hset('chris_taste_model', 'saturation_preference', preferences['saturation_preferences']['average'])
    redis_client.hset('chris_taste_model', 'complexity_preference', preferences['complexity_preferences']['average'])
    redis_client.hset('chris_taste_model', 'style_preference', preferences['complexity_preferences']['preference_type'])
    redis_client.hset('chris_taste_model', 'color_tone', preferences['color_preferences']['dominant_tone'])
    
    # Store companies analyzed
    companies = preferences['analysis_metadata']['companies_analyzed']
    for company in companies:
        redis_client.sadd('burch_portfolio_real', company)
    
    # Update model metadata
    redis_client.set('model_version', 'real_data_v1.0')
    redis_client.set('real_data_source', 'actual_portfolio_analysis')
    redis_client.set('companies_analyzed_count', len(companies))
    
    print(f"✅ SUCCESS! Loaded real preferences from {len(companies)} companies")
    print(f"🎨 Brightness: {preferences['brightness_preferences']['average']:.1f}/255 (bright)")
    print(f"🌈 Saturation: {preferences['saturation_preferences']['average']:.1f}/255 (muted)")
    print(f"🎪 Style: {preferences['complexity_preferences']['preference_type']}")
    print(f"🎯 Color: {preferences['color_preferences']['dominant_tone']} tones")
    
    # Test that data was stored
    stored_brightness = redis_client.hget('chris_taste_model', 'brightness_preference')
    print(f"🔍 Verification: Stored brightness = {stored_brightness.decode('utf-8')}")
    
except Exception as e:
    print(f"❌ Error: {e}")
    print("Try: docker-compose down && docker-compose up -d")
