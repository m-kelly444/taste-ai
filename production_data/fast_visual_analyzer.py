import json
import requests
from PIL import Image
import numpy as np
import io
import time
from urllib.parse import urljoin
import signal

class TimeoutError(Exception):
    pass

def timeout_handler(signum, frame):
    raise TimeoutError()

def safe_request(url, timeout=5):
    """Make request with strict timeout"""
    try:
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(timeout)
        
        response = requests.get(url, timeout=timeout, headers={
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'
        })
        
        signal.alarm(0)  # Cancel alarm
        return response
    except (TimeoutError, requests.exceptions.RequestException):
        signal.alarm(0)
        return None

def analyze_brand_fast(company, website):
    """Fast brand analysis with timeouts"""
    print(f"⚡ Analyzing {company}...")
    
    try:
        # Get homepage with timeout
        response = safe_request(website, timeout=5)
        if not response or response.status_code != 200:
            return None
        
        # Quick image extraction - just first few images
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(response.content, 'html.parser')
        
        images = soup.find_all('img')[:5]  # Only first 5 images
        analyzed_images = []
        
        for img in images:
            src = img.get('src') or img.get('data-src')
            if not src:
                continue
            
            img_url = urljoin(website, src)
            
            # Quick image analysis
            img_response = safe_request(img_url, timeout=3)
            if not img_response:
                continue
            
            try:
                image = Image.open(io.BytesIO(img_response.content))
                if image.mode != 'RGB':
                    image = image.convert('RGB')
                
                # Fast analysis
                img_array = np.array(image)
                pixels = img_array.reshape(-1, 3)
                
                analysis = {
                    'brightness': float(np.mean(pixels)),
                    'saturation': float(np.std(pixels)),
                    'dominant_color': pixels[0].tolist(),  # Just first pixel as sample
                    'size': image.size
                }
                
                analyzed_images.append(analysis)
                
                if len(analyzed_images) >= 3:  # Max 3 images per site
                    break
                    
            except Exception:
                continue
        
        if analyzed_images:
            # Calculate averages
            avg_brightness = np.mean([img['brightness'] for img in analyzed_images])
            avg_saturation = np.mean([img['saturation'] for img in analyzed_images])
            
            return {
                'company': company,
                'website': website,
                'visual_analysis': {
                    'average_brightness': float(avg_brightness),
                    'average_saturation': float(avg_saturation),
                    'visual_complexity': float(avg_saturation / 255.0),
                    'images_analyzed': len(analyzed_images)
                }
            }
    
    except Exception as e:
        print(f"Error analyzing {company}: {e}")
        return None

# Load known websites
with open('production_data/known_websites.json', 'r') as f:
    websites = json.load(f)

# Analyze each company quickly
results = {}
total = len(websites)

for i, (company, website) in enumerate(websites.items(), 1):
    print(f"[{i}/{total}] Processing {company}...")
    
    analysis = analyze_brand_fast(company, website)
    if analysis:
        results[company] = analysis
        print(f"✅ Analyzed {company}")
    else:
        print(f"❌ Failed {company}")

# Save results
with open('production_data/visual_analysis_fast.json', 'w') as f:
    json.dump(results, f, indent=2)

print(f"\n✅ FAST ANALYSIS COMPLETE!")
print(f"📊 Successfully analyzed: {len(results)}/{total} companies")
