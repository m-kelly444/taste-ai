import re
import json
from bs4 import BeautifulSoup
import requests
import time

# Known current portfolio (from search results)
CURRENT_PORTFOLIO = [
    "Addepar", "BaubleBar", "Blink Health", "BILL", "Cerebral", 
    "Chubbies Shorts", "Claire", "Dirty Lemon", "ED by Ellen",
    "Elite Body Sculpture", "Faena Hotel", "Field Trip Jerky",
    "Index", "Jawbone", "Little Duck Organics", "Material Bank",
    "Next Jump", "Nihiwatu Resort", "NuLabel Technologies",
    "Octopus Interactive", "Outdoor Voices", "Perfect Moment",
    "Poppin", "Powermat", "Pypestream", "Rain", "Rappi",
    "Rowing Blazers", "Snowe", "Solid & Striped", "The Void",
    "Tory Burch", "Upstack", "Verificar", "Voss Water"
]

def discover_company_website(company_name):
    """Actually find company websites"""
    print(f"🔍 Finding website for {company_name}...")
    
    # Try common patterns
    variations = [
        company_name.lower().replace(' ', '').replace('&', 'and'),
        company_name.lower().replace(' ', ''),
        company_name.lower().replace(' ', '-'),
        ''.join([word[0].lower() + word[1:] for word in company_name.split()])
    ]
    
    for variation in variations:
        for tld in ['.com', '.co', '.io']:
            url = f"https://www.{variation}{tld}"
            try:
                response = requests.get(url, timeout=10, allow_redirects=True)
                if response.status_code == 200:
                    print(f"✅ Found: {url}")
                    return url
            except:
                continue
            
            # Try without www
            url = f"https://{variation}{tld}"
            try:
                response = requests.get(url, timeout=10, allow_redirects=True)
                if response.status_code == 200:
                    print(f"✅ Found: {url}")
                    return url
            except:
                continue
    
    print(f"❌ No website found for {company_name}")
    return None

# Discover websites for all companies
discovered_websites = {}

for company in CURRENT_PORTFOLIO:
    website = discover_company_website(company)
    if website:
        discovered_websites[company] = {
            'website': website,
            'status': 'active',
            'discovered_at': time.time()
        }
    time.sleep(1)  # Rate limiting

# Save results
with open('production_data/brands/websites/discovered.json', 'w') as f:
    json.dump(discovered_websites, f, indent=2)

print(f"✅ Discovered {len(discovered_websites)} live company websites")
