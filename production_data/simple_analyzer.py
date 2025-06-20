import json
import requests
from PIL import Image
import numpy as np
import io
from urllib.parse import urljoin
import time

def safe_request(url, max_time=5):
    """Make request with simple timeout"""
    try:
        response = requests.get(url, timeout=max_time, headers={
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'
        })
        return response
    except:
        return None

def analyze_brand_simple(company, website):
    """Simple brand analysis"""
    print(f"⚡ Analyzing {company}...")
    
    try:
        # Get homepage
        response = safe_request(website)
        if not response or response.status_code != 200:
            print(f"❌ Failed to load {website}")
            return None
        
        # Quick image extraction
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(response.content, 'html.parser')
        
        images = soup.find_all('img')[:3]  # Only first 3 images
        analyzed_images = []
        
        for img in images:
            src = img.get('src') or img.get('data-src')
            if not src:
                continue
            
            img_url = urljoin(website, src)
            
            # Try to analyze image
            img_response = safe_request(img_url, 3)
            if not img_response:
                continue
            
            try:
                image = Image.open(io.BytesIO(img_response.content))
                if image.mode != 'RGB':
                    image = image.convert('RGB')
                
                # Simple analysis
                img_array = np.array(image)
                pixels = img_array.reshape(-1, 3)
                
                # Sample pixels for speed
                sample_size = min(1000, len(pixels))
                sample_pixels = pixels[:sample_size]
                
                analysis = {
                    'brightness': float(np.mean(sample_pixels)),
                    'saturation': float(np.std(sample_pixels)),
                    'red_avg': float(np.mean(sample_pixels[:, 0])),
                    'green_avg': float(np.mean(sample_pixels[:, 1])),
                    'blue_avg': float(np.mean(sample_pixels[:, 2])),
                    'size': image.size
                }
                
                analyzed_images.append(analysis)
                break  # Just analyze first successful image
                
            except Exception as e:
                print(f"   Error analyzing image: {e}")
                continue
        
        if analyzed_images:
            analysis = analyzed_images[0]  # Use first image
            
            return {
                'company': company,
                'website': website,
                'visual_analysis': {
                    'average_brightness': analysis['brightness'],
                    'average_saturation': analysis['saturation'],
                    'visual_complexity': analysis['saturation'] / 255.0,
                    'color_profile': {
                        'red': analysis['red_avg'],
                        'green': analysis['green_avg'],
                        'blue': analysis['blue_avg']
                    },
                    'images_analyzed': 1
                },
                'status': 'success'
            }
        else:
            print(f"   No images found for {company}")
            return None
    
    except Exception as e:
        print(f"   Error analyzing {company}: {e}")
        return None

# Load known websites
print("📊 Loading website list...")
with open('production_data/known_websites.json', 'r') as f:
    websites = json.load(f)

print(f"🔍 Analyzing {len(websites)} companies...")

# Analyze each company
results = {}
successful = 0
failed = 0

for i, (company, website) in enumerate(websites.items(), 1):
    print(f"[{i}/{len(websites)}] {company}")
    
    analysis = analyze_brand_simple(company, website)
    if analysis:
        results[company] = analysis
        successful += 1
        print(f"✅ Success")
    else:
        failed += 1
        print(f"❌ Failed")
    
    # Small delay to be nice to servers
    time.sleep(0.5)

# Save results
with open('production_data/visual_analysis_results.json', 'w') as f:
    json.dump(results, f, indent=2)

print(f"\n🎯 ANALYSIS COMPLETE!")
print(f"✅ Successful: {successful}")
print(f"❌ Failed: {failed}")
print(f"📊 Success rate: {successful/(successful+failed)*100:.1f}%")
