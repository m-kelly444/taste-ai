#!/bin/bash

cd taste-ai

python3 -c "
import requests
from bs4 import BeautifulSoup
import json
import re
import time
from collections import defaultdict
import os
from urllib.parse import urljoin, urlparse

class AdaptivePageDiscovery:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        })
        
        self.extraction_methods = []
        self.successful_methods = []
        self.page_analysis = {}
        self.discovered_companies = []
        
    def analyze_page_structure_completely(self, url):
        print(f'🔍 COMPLETELY analyzing page structure: {url}')
        
        try:
            response = self.session.get(url, timeout=20)
            print(f'   Status: {response.status_code}')
            
            if response.status_code != 200:
                print(f'   ❌ Cannot access page: HTTP {response.status_code}')
                return None
            
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # COMPLETE page analysis - no assumptions
            analysis = {
                'page_title': soup.title.string if soup.title else None,
                'total_elements': len(soup.find_all()),
                'all_tags': self.get_all_tag_types(soup),
                'all_classes': self.get_all_classes(soup),
                'all_ids': self.get_all_ids(soup),
                'all_links': self.get_all_links(soup),
                'all_images': self.get_all_images(soup),
                'all_text_content': self.get_text_content_structure(soup),
                'all_scripts': self.get_all_scripts(soup),
                'all_json_data': self.find_all_json_data(soup),
                'page_text_sample': soup.get_text()[:1000]
            }
            
            print(f'   📊 Page Analysis Complete:')
            print(f'      Total Elements: {analysis[\"total_elements\"]}')
            print(f'      Unique Tags: {len(analysis[\"all_tags\"])}')
            print(f'      Classes Found: {len(analysis[\"all_classes\"])}')
            print(f'      Links Found: {len(analysis[\"all_links\"])}')
            print(f'      Scripts Found: {len(analysis[\"all_scripts\"])}')
            
            self.page_analysis = analysis
            return soup
            
        except Exception as e:
            print(f'   ❌ Page analysis error: {e}')
            return None
    
    def get_all_tag_types(self, soup):
        return list(set(tag.name for tag in soup.find_all() if tag.name))
    
    def get_all_classes(self, soup):
        classes = []
        for element in soup.find_all(class_=True):
            classes.extend(element.get('class', []))
        return list(set(classes))
    
    def get_all_ids(self, soup):
        return [element.get('id') for element in soup.find_all(id=True)]
    
    def get_all_links(self, soup):
        links = []
        for link in soup.find_all('a', href=True):
            links.append({
                'href': link.get('href'),
                'text': link.get_text().strip(),
                'classes': link.get('class', []),
                'id': link.get('id')
            })
        return links
    
    def get_all_images(self, soup):
        images = []
        for img in soup.find_all('img'):
            images.append({
                'src': img.get('src'),
                'alt': img.get('alt'),
                'classes': img.get('class', []),
                'id': img.get('id')
            })
        return images
    
    def get_text_content_structure(self, soup):
        text_structure = {}
        
        # Get text from different types of elements
        for tag in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'div', 'span', 'li']:
            elements = soup.find_all(tag)
            text_structure[tag] = [elem.get_text().strip() for elem in elements if elem.get_text().strip()]
        
        return text_structure
    
    def get_all_scripts(self, soup):
        scripts = []
        for script in soup.find_all('script'):
            script_data = {
                'type': script.get('type'),
                'src': script.get('src'),
                'content_preview': script.string[:200] if script.string else None
            }
            scripts.append(script_data)
        return scripts
    
    def find_all_json_data(self, soup):
        json_data = []
        
        # Look in script tags
        for script in soup.find_all('script'):
            if script.string:
                try:
                    # Try to find JSON objects
                    content = script.string
                    
                    # Look for JSON-like structures
                    json_patterns = [
                        r'\\{[^{}]*\"[^\"]*\"[^{}]*\\}',  # Simple JSON objects
                        r'\\[[^\\[\\]]*\\{[^}]*\\}[^\\[\\]]*\\]',  # Arrays of objects
                    ]
                    
                    for pattern in json_patterns:
                        matches = re.findall(pattern, content)
                        for match in matches:
                            try:
                                parsed = json.loads(match)
                                json_data.append({
                                    'source': 'script_tag',
                                    'data': parsed,
                                    'raw': match[:100]
                                })
                            except:
                                continue
                except:
                    continue
        
        # Look for data attributes
        for element in soup.find_all(attrs=lambda x: x and any(attr.startswith('data-') for attr in x.keys())):
            for attr, value in element.attrs.items():
                if attr.startswith('data-'):
                    try:
                        parsed = json.loads(value)
                        json_data.append({
                            'source': f'data_attribute_{attr}',
                            'data': parsed,
                            'element': element.name
                        })
                    except:
                        continue
        
        return json_data
    
    def try_all_extraction_methods(self, soup):
        print('🧪 Trying ALL possible extraction methods...')
        
        methods_to_try = [
            ('method_1_obvious_portfolio_sections', self.extract_method_1_portfolio_sections),
            ('method_2_card_grid_layout', self.extract_method_2_card_layouts),
            ('method_3_list_items', self.extract_method_3_list_items),
            ('method_4_table_data', self.extract_method_4_table_data),
            ('method_5_json_embedded', self.extract_method_5_json_data),
            ('method_6_link_analysis', self.extract_method_6_link_analysis),
            ('method_7_image_analysis', self.extract_method_7_image_analysis),
            ('method_8_text_pattern_matching', self.extract_method_8_text_patterns),
            ('method_9_class_name_hunting', self.extract_method_9_class_hunting),
            ('method_10_attribute_analysis', self.extract_method_10_attribute_analysis),
            ('method_11_nested_div_structures', self.extract_method_11_nested_divs),
            ('method_12_ajax_data_sources', self.extract_method_12_ajax_sources),
            ('method_13_iframe_content', self.extract_method_13_iframe_content),
            ('method_14_css_selector_patterns', self.extract_method_14_css_patterns),
            ('method_15_semantic_html', self.extract_method_15_semantic_html)
        ]
        
        successful_extractions = []
        
        for method_name, method_func in methods_to_try:
            print(f'   Trying {method_name}...')
            
            try:
                results = method_func(soup)
                
                if results and len(results) > 0:
                    print(f'      ✅ SUCCESS: Found {len(results)} companies with {method_name}')
                    successful_extractions.append({
                        'method': method_name,
                        'results': results,
                        'count': len(results)
                    })
                else:
                    print(f'      ❌ No results from {method_name}')
                    
            except Exception as e:
                print(f'      ❌ Error in {method_name}: {e}')
        
        return successful_extractions
    
    def extract_method_1_portfolio_sections(self, soup):
        # Look for obvious portfolio/company sections
        companies = []
        
        portfolio_selectors = [
            '[class*=\"portfolio\"]',
            '[class*=\"company\"]', 
            '[class*=\"investment\"]',
            '[class*=\"brand\"]',
            '[id*=\"portfolio\"]',
            '[id*=\"company\"]'
        ]
        
        for selector in portfolio_selectors:
            elements = soup.select(selector)
            for element in elements:
                company_data = self.extract_company_from_element(element)
                if company_data:
                    companies.append(company_data)
        
        return companies
    
    def extract_method_2_card_layouts(self, soup):
        # Look for card-based layouts
        companies = []
        
        card_selectors = [
            '.card',
            '.item',
            '.tile',
            '.box',
            '[class*=\"card\"]',
            '[class*=\"item\"]',
            '[class*=\"tile\"]'
        ]
        
        for selector in card_selectors:
            cards = soup.select(selector)
            if len(cards) > 3:  # If we found multiple cards, might be portfolio
                for card in cards:
                    company_data = self.extract_company_from_element(card)
                    if company_data:
                        companies.append(company_data)
        
        return companies
    
    def extract_method_3_list_items(self, soup):
        # Look for list-based layouts
        companies = []
        
        # Try different list structures
        list_containers = soup.find_all(['ul', 'ol'])
        for container in list_containers:
            items = container.find_all('li')
            if len(items) > 2:  # Multiple items might be companies
                for item in items:
                    company_data = self.extract_company_from_element(item)
                    if company_data:
                        companies.append(company_data)
        
        return companies
    
    def extract_method_4_table_data(self, soup):
        # Look for table-based data
        companies = []
        
        tables = soup.find_all('table')
        for table in tables:
            rows = table.find_all('tr')
            for row in rows:
                cells = row.find_all(['td', 'th'])
                if len(cells) > 1:  # Multiple columns might contain company data
                    company_data = self.extract_company_from_table_row(cells)
                    if company_data:
                        companies.append(company_data)
        
        return companies
    
    def extract_method_5_json_data(self, soup):
        # Extract from JSON data found on page
        companies = []
        
        for json_item in self.page_analysis.get('all_json_data', []):
            try:
                data = json_item['data']
                companies_from_json = self.extract_companies_from_json_recursive(data)
                companies.extend(companies_from_json)
            except:
                continue
        
        return companies
    
    def extract_method_6_link_analysis(self, soup):
        # Analyze all links for patterns
        companies = []
        
        external_links = []
        for link_data in self.page_analysis.get('all_links', []):
            href = link_data.get('href', '')
            if href and self.is_external_website_link(href):
                external_links.append(link_data)
        
        # If we found multiple external links, they might be portfolio companies
        if len(external_links) > 3:
            for link_data in external_links:
                company_data = {
                    'name': link_data.get('text'),
                    'url': link_data.get('href'),
                    'source': 'link_analysis'
                }
                if company_data['name'] or company_data['url']:
                    companies.append(company_data)
        
        return companies
    
    def extract_method_7_image_analysis(self, soup):
        # Look for company logos/images
        companies = []
        
        for img_data in self.page_analysis.get('all_images', []):
            alt_text = img_data.get('alt', '')
            src = img_data.get('src', '')
            
            # Check if this looks like a company logo
            if any(keyword in (alt_text + src).lower() for keyword in ['logo', 'company', 'brand']):
                company_data = {
                    'name': alt_text,
                    'url': None,
                    'source': 'image_analysis',
                    'logo_src': src
                }
                if company_data['name']:
                    companies.append(company_data)
        
        return companies
    
    def extract_method_8_text_patterns(self, soup):
        # Look for text patterns that indicate companies
        companies = []
        
        page_text = soup.get_text()
        
        # Look for company name patterns
        company_patterns = [
            r'\\b[A-Z][a-z]+\\s+(?:Inc|Corp|LLC|Ltd|Co)\\.?\\b',
            r'\\b[A-Z][a-zA-Z]+\\.com\\b',
            r'www\\.[a-zA-Z0-9]+\\.[a-z]{2,3}\\b'
        ]
        
        for pattern in company_patterns:
            matches = re.findall(pattern, page_text)
            for match in matches:
                companies.append({
                    'name': match,
                    'url': None,
                    'source': 'text_pattern_matching'
                })
        
        return companies
    
    def extract_method_9_class_hunting(self, soup):
        # Hunt through all classes for company-related ones
        companies = []
        
        company_related_classes = [cls for cls in self.page_analysis.get('all_classes', []) 
                                 if any(keyword in cls.lower() for keyword in 
                                       ['company', 'brand', 'portfolio', 'investment', 'client', 'partner'])]
        
        for class_name in company_related_classes:
            elements = soup.find_all(class_=class_name)
            for element in elements:
                company_data = self.extract_company_from_element(element)
                if company_data:
                    companies.append(company_data)
        
        return companies
    
    def extract_method_10_attribute_analysis(self, soup):
        # Analyze all data attributes
        companies = []
        
        for element in soup.find_all():
            for attr, value in element.attrs.items():
                if attr.startswith('data-') and any(keyword in attr.lower() for keyword in ['company', 'brand', 'name', 'url']):
                    company_data = {
                        'name': value if 'name' in attr else None,
                        'url': value if 'url' in attr else None,
                        'source': f'data_attribute_{attr}'
                    }
                    if company_data['name'] or company_data['url']:
                        companies.append(company_data)
        
        return companies
    
    def extract_method_11_nested_divs(self, soup):
        # Look for nested div structures that might contain companies
        companies = []
        
        # Find divs that contain multiple child divs (might be company grid)
        container_divs = soup.find_all('div')
        for container in container_divs:
            child_divs = container.find_all('div', recursive=False)
            if 3 <= len(child_divs) <= 20:  # Reasonable number for portfolio
                for child in child_divs:
                    company_data = self.extract_company_from_element(child)
                    if company_data:
                        companies.append(company_data)
        
        return companies
    
    def extract_method_12_ajax_sources(self, soup):
        # Look for AJAX/API endpoints that might contain data
        companies = []
        
        # Look for fetch/ajax calls in scripts
        for script in soup.find_all('script'):
            if script.string:
                content = script.string
                
                # Look for API endpoints
                api_patterns = [
                    r'fetch\\([\"\\']([^\"\\']+)[\"\\']\\)',
                    r'\\$\\.get\\([\"\\']([^\"\\']+)[\"\\']\\)',
                    r'axios\\.get\\([\"\\']([^\"\\']+)[\"\\']\\)'
                ]
                
                for pattern in api_patterns:
                    matches = re.findall(pattern, content)
                    for match in matches:
                        if 'portfolio' in match.lower() or 'company' in match.lower():
                            # Found potential API endpoint - would need separate request
                            companies.append({
                                'name': f'API_ENDPOINT: {match}',
                                'url': match,
                                'source': 'ajax_endpoint_discovery'
                            })
        
        return companies
    
    def extract_method_13_iframe_content(self, soup):
        # Check iframe sources
        companies = []
        
        iframes = soup.find_all('iframe')
        for iframe in iframes:
            src = iframe.get('src')
            if src and ('portfolio' in src.lower() or 'company' in src.lower()):
                companies.append({
                    'name': f'IFRAME_SOURCE: {src}',
                    'url': src,
                    'source': 'iframe_analysis'
                })
        
        return companies
    
    def extract_method_14_css_patterns(self, soup):
        # Look for CSS-based patterns
        companies = []
        
        # Try various CSS selector combinations
        css_selectors = [
            'article',
            'section',
            '.row > div',
            '.grid > div',
            '.container > div',
            '[role=\"listitem\"]',
            '[itemtype*=\"Organization\"]'
        ]
        
        for selector in css_selectors:
            try:
                elements = soup.select(selector)
                if 3 <= len(elements) <= 50:  # Reasonable portfolio size
                    for element in elements:
                        company_data = self.extract_company_from_element(element)
                        if company_data:
                            companies.append(company_data)
            except:
                continue
        
        return companies
    
    def extract_method_15_semantic_html(self, soup):
        # Look for semantic HTML structures
        companies = []
        
        # Check for microdata or structured markup
        for element in soup.find_all(attrs={'itemtype': True}):
            itemtype = element.get('itemtype', '')
            if 'Organization' in itemtype or 'Corporation' in itemtype:
                company_data = self.extract_company_from_microdata(element)
                if company_data:
                    companies.append(company_data)
        
        return companies
    
    def extract_company_from_element(self, element):
        # Generic company extraction from any element
        company_data = {'name': None, 'url': None, 'description': None}
        
        # Try to find company name
        text = element.get_text().strip()
        if text and len(text) < 100 and self.might_be_company_name(text):
            company_data['name'] = text
        
        # Try to find URL
        link = element.find('a', href=True)
        if link:
            href = link.get('href')
            if self.is_external_website_link(href):
                company_data['url'] = href
        
        # Try to find description
        desc_element = element.find(['p', 'div'], class_=lambda x: x and any(keyword in ' '.join(x).lower() for keyword in ['desc', 'about', 'summary']))
        if desc_element:
            desc_text = desc_element.get_text().strip()
            if desc_text and len(desc_text) > 10:
                company_data['description'] = desc_text[:200]
        
        # Only return if we found something useful
        if company_data['name'] or company_data['url']:
            return company_data
        
        return None
    
    def extract_company_from_table_row(self, cells):
        # Extract company from table row
        if len(cells) >= 2:
            name_cell = cells[0].get_text().strip()
            url_cell = cells[1].get_text().strip() if len(cells) > 1 else ''
            
            if self.might_be_company_name(name_cell):
                return {
                    'name': name_cell,
                    'url': url_cell if self.is_external_website_link(url_cell) else None,
                    'source': 'table_extraction'
                }
        
        return None
    
    def extract_companies_from_json_recursive(self, data):
        companies = []
        
        if isinstance(data, dict):
            # Look for company-like data structures
            if any(key in data for key in ['name', 'company', 'brand', 'organization']):
                company = {
                    'name': data.get('name') or data.get('company') or data.get('brand') or data.get('organization'),
                    'url': data.get('url') or data.get('website') or data.get('homepage'),
                    'description': data.get('description') or data.get('about'),
                    'source': 'json_extraction'
                }
                if company['name'] or company['url']:
                    companies.append(company)
            
            # Recursively search nested data
            for value in data.values():
                if isinstance(value, (dict, list)):
                    companies.extend(self.extract_companies_from_json_recursive(value))
        
        elif isinstance(data, list):
            for item in data:
                companies.extend(self.extract_companies_from_json_recursive(item))
        
        return companies
    
    def extract_company_from_microdata(self, element):
        name = None
        url = None
        
        # Look for name property
        name_element = element.find(attrs={'itemprop': 'name'})
        if name_element:
            name = name_element.get_text().strip()
        
        # Look for URL property
        url_element = element.find(attrs={'itemprop': 'url'})
        if url_element:
            url = url_element.get('href') or url_element.get_text().strip()
        
        if name or url:
            return {
                'name': name,
                'url': url,
                'source': 'microdata_extraction'
            }
        
        return None
    
    def might_be_company_name(self, text):
        if not text or len(text) > 100:
            return False
        
        # Basic heuristics for company names
        indicators = [
            len(text.split()) <= 5,  # Not too long
            any(char.isupper() for char in text),  # Has uppercase
            not text.lower().startswith(('the ', 'a ', 'an ')),  # Not article
            text.count(' ') <= 3  # Not too many words
        ]
        
        return sum(indicators) >= 2
    
    def is_external_website_link(self, url):
        if not url:
            return False
        
        return (url.startswith('http') and 
                not any(social in url.lower() for social in ['facebook', 'twitter', 'instagram', 'linkedin', 'youtube']) and
                '.' in url)
    
    def run_adaptive_discovery(self, url):
        print(f'🚀 Running adaptive discovery on: {url}')
        print('=' * 70)
        
        # Step 1: Complete page analysis
        soup = self.analyze_page_structure_completely(url)
        if not soup:
            return {'success': False, 'error': 'Could not access or parse page'}
        
        # Step 2: Try all extraction methods
        successful_extractions = self.try_all_extraction_methods(soup)
        
        # Step 3: Compile results
        all_companies = []
        for extraction in successful_extractions:
            all_companies.extend(extraction['results'])
        
        # Step 4: Deduplicate and clean
        unique_companies = self.deduplicate_companies(all_companies)
        
        results = {
            'success': True,
            'total_methods_tried': 15,
            'successful_methods': len(successful_extractions),
            'companies_found': len(unique_companies),
            'companies': unique_companies,
            'successful_extraction_methods': [e['method'] for e in successful_extractions],
            'page_analysis': self.page_analysis
        }
        
        return results
    
    def deduplicate_companies(self, companies):
        seen = set()
        unique = []
        
        for company in companies:
            # Create identifier for deduplication
            identifier = (company.get('name', '').lower(), company.get('url', '').lower())
            
            if identifier not in seen and (company.get('name') or company.get('url')):
                seen.add(identifier)
                unique.append(company)
        
        return unique
    
    def save_discovery_results(self, results):
        print('💾 Saving adaptive discovery results...')
        
        os.makedirs('adaptive_discovery', exist_ok=True)
        
        with open('adaptive_discovery/portfolio_discovery_results.json', 'w') as f:
            json.dump(results, f, indent=2, default=str)
        
        return True

# Run the adaptive discovery
discoverer = AdaptivePageDiscovery()
results = discoverer.run_adaptive_discovery('https://www.burchcreativecapital.com/portfolio/')
discoverer.save_discovery_results(results)

print('\\n🎯 ADAPTIVE DISCOVERY COMPLETE')
print('=' * 50)
print(f'Success: {results[\"success\"]}')

if results['success']:
    print(f'Methods Tried: {results[\"total_methods_tried\"]}')
    print(f'Successful Methods: {results[\"successful_methods\"]}')
    print(f'Companies Found: {results[\"companies_found\"]}')
    
    print(f'\\n✅ Working Extraction Methods:')
    for method in results['successful_extraction_methods']:
        print(f'   • {method}')
    
    print(f'\\n🏢 Discovered Companies:')
    for i, company in enumerate(results['companies'][:10], 1):
        name = company.get('name', 'Unknown')
        url = company.get('url', 'No URL')
        source = company.get('source', 'Unknown source')
        print(f'   {i}. {name} - {url} ({source})')
    
    if results['companies_found'] > 10:
        print(f'   ... and {results[\"companies_found\"] - 10} more companies')

else:
    print(f'❌ Discovery failed: {results.get(\"error\", \"Unknown error\")}')

print('\\n📊 Page Analysis Summary:')
analysis = results.get('page_analysis', {})
print(f'   Total Elements: {analysis.get(\"total_elements\", 0)}')
print(f'   Unique Tags: {len(analysis.get(\"all_tags\", []))}')
print(f'   CSS Classes: {len(analysis.get(\"all_classes\", []))}')
print(f'   Links Found: {len(analysis.get(\"all_links\", []))}')

print('\\n✅ Results saved to: adaptive_discovery/portfolio_discovery_results.json')
print('🔄 System tried EVERY possible extraction method until finding what works!')
"

echo "Adaptive portfolio discovery complete"