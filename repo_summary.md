# LLM Training Repository - Burch Creative Capital Portfolio Analysis

## Project Overview
This repository contains scripts to train an LLM on a company's portfolio by scraping their portfolio, finding actual websites, and performing advanced visual/content analysis.

## Architecture
1. **Portfolio Scraping**: Extract portfolio companies from VC website
2. **Website Discovery**: Find actual company websites using AI/search
3. **Visual Analysis**: Download and analyze product images using computer vision
4. **Pattern Recognition**: Identify investment patterns and characteristics
5. **Training Data Generation**: Create structured data for LLM training

## Scripts Overview

### 01_fetch_portfolio.sh
- Fetches the complete portfolio page HTML from Burch Creative Capital
- Handles compression, encoding, and browser headers
- Outputs clean, readable HTML for parsing

### 02_parse_portfolio.sh  
- Parses portfolio companies from the fetched HTML
- Extracts company names from description patterns
- Handles Nuxt.js dynamic content structure

### 03_clean_company_names.sh
- Cleans company names from descriptions
- Extracts actual company names from marketing text
- Removes duplicates and normalizes names

### 04_deep_portfolio_extraction.sh
- Comprehensive extraction using multiple methods:
  - API endpoint discovery (found WordPress API)
  - Sitemap analysis
  - Text pattern matching
  - Embedded JSON data extraction

### 05_advanced_ai_analysis.sh (Advanced)
- State-of-the-art 2025 AI/ML analysis
- Uses CLIP, BLIP-2, GPT-4V, Claude, Gemini
- Playwright browser automation
- Advanced computer vision analysis
- Requires API keys for full functionality

### 05_basic_visual_analysis.sh (Basic)
- Basic visual analysis without API dependencies
- OpenCV-based image analysis
- Color, brightness, contrast analysis
- Visual complexity measurement
- Works with minimal setup

### 00_install_dependencies.sh
- Installs all required Python packages
- Sets up Playwright browsers
- Verifies installation

## Key Discoveries

### Portfolio Companies Found (via WordPress API)
- STAUD: Fashion/clothing brand
- BaubleBar: Jewelry and accessories  
- C Wonder: Women's fashion
- Guggenheim Partners: Financial services
- Win Brands: Holding company (Homesick, Gravity, QALO)
- Faena: Luxury hospitality
- NIHI Sumba: Luxury resort
- Rappi: Latin American delivery app
- Barbers Surgeon Guild: Hair restoration

### Technical Insights
- Portfolio data served via WordPress API endpoints
- Nuxt.js frontend with server-side rendering
- Company descriptions follow pattern: "Description text CompanyName"
- Images require real browser rendering for dynamic content

### Visual Analysis Capabilities
- Dominant color extraction using K-means clustering
- Color harmony analysis (monochromatic, analogous, complementary)
- Visual complexity via edge detection
- Texture analysis using Local Binary Patterns
- Composition analysis (rule of thirds, symmetry)
- Style classification based on visual metrics

## Data Structure

### Company Data Format
```json
{
  "name": "Company Name",
  "website": "https://company.com",
  "visual_analysis": {
    "color_analysis": {
      "dominant_colors": [...],
      "color_scheme": "monochromatic|analogous|complementary",
      "average_saturation": 0.0-100.0,
      "average_brightness": 0.0-255.0
    },
    "visual_complexity": {
      "edge_density": 0.0-1.0,
      "texture_complexity": 0.0-255.0,
      "complexity_score": calculated_metric
    },
    "content_categories": ["bright_aesthetic", "minimalist_clean", ...]
  }
}
```

## Next Steps for LLM Training

1. **Expand Analysis**: Analyze more portfolio companies
2. **Pattern Recognition**: Identify common visual/brand characteristics
3. **Investment Thesis Extraction**: Correlate visual patterns with investment decisions
4. **Training Dataset**: Structure data for LLM fine-tuning
5. **Model Training**: Train LLM on investment pattern recognition

## Dependencies
- Python 3.8+
- OpenCV, PIL, NumPy, scikit-learn
- BeautifulSoup, requests
- Playwright (for advanced analysis)
- Transformers, PyTorch (for AI models)
- API access: OpenAI, Anthropic, Google AI

## Usage
```bash
# Basic setup
./00_install_dependencies.sh
./01_fetch_portfolio.sh
./04_deep_portfolio_extraction.sh
./05_basic_visual_analysis.sh

# Advanced AI analysis (requires API keys)
./05_advanced_ai_analysis.sh
```
## Repository Structure
```
./setup.sh
./frontend/.vite/deps_temp_c3125080/package.json
./taste-ai/start_production.sh
./taste-ai/adaptive_discovery/portfolio_discovery_results.json
./taste-ai/frontend/index.html
./taste-ai/frontend/package.json
./taste-ai/test_report.json
./taste-ai/backend/config/optimized_performance.json
./taste-ai/backend/config/optimized_monitoring.json
./taste-ai/backend/venv/lib/python3.12/site-packages/uvicorn-0.24.0.dist-info/licenses/LICENSE.md
./taste-ai/backend/venv/lib/python3.12/site-packages/starlette-0.27.0.dist-info/licenses/LICENSE.md
./taste-ai/backend/venv/lib/python3.12/site-packages/huggingface_hub/templates/datasetcard_template.md
./taste-ai/backend/venv/lib/python3.12/site-packages/huggingface_hub/templates/modelcard_template.md
./taste-ai/backend/venv/lib/python3.12/site-packages/torch/utils/model_dump/skeleton.html
./taste-ai/backend/venv/lib/python3.12/site-packages/httpcore-1.0.9.dist-info/licenses/LICENSE.md
./taste-ai/backend/venv/lib/python3.12/site-packages/numpy/random/LICENSE.md
./taste-ai/backend/venv/lib/python3.12/site-packages/httpx-0.25.2.dist-info/licenses/LICENSE.md
./taste-ai/backend/venv/lib/python3.12/site-packages/torchgen/packaged/autograd/README.md
./taste-ai/backend/venv/lib/python3.12/site-packages/setuptools/config/setuptools.schema.json
./taste-ai/backend/venv/lib/python3.12/site-packages/setuptools/config/distutils.schema.json
```

## File Sizes
```
-rwxr-xr-x  1 maevekelly  staff   6.9K Jun 19 22:38 setup.sh
Data directory:
440K	data/portfolio
```
