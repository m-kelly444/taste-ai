#!/bin/bash

# Script 0: Install all required dependencies for advanced AI analysis
# Usage: ./00_install_dependencies.sh

echo "Installing dependencies for state-of-the-art AI analysis..."

# Check if pip is available
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 not found. Please install Python 3 and pip first."
    exit 1
fi

# Update pip
echo "Updating pip..."
pip3 install --upgrade pip

# Install core dependencies
echo "Installing core Python packages..."
pip3 install requests beautifulsoup4 lxml

# Install computer vision and ML libraries with robust OpenCV handling
echo "Installing computer vision libraries..."
echo "Installing numpy and scipy first..."
pip3 install numpy scipy

echo "Installing Pillow..."
pip3 install pillow

echo "Installing OpenCV (trying headless version first)..."
if pip3 install opencv-python-headless; then
    echo "✓ OpenCV headless installation successful"
else
    echo "Headless failed, trying regular opencv-python..."
    if pip3 install opencv-python; then
        echo "✓ OpenCV regular installation successful"
    else
        echo "⚠️  OpenCV installation failed. Continuing with other packages..."
        echo "You may need to install OpenCV manually later."
    fi
fi

# Install scikit packages
echo "Installing scikit libraries..."
pip3 install scikit-learn scikit-image

# Install deep learning frameworks
echo "Installing PyTorch..."
if pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu; then
    echo "✓ PyTorch installation successful"
else
    echo "PyTorch installation failed, trying without index URL..."
    pip3 install torch torchvision torchaudio
fi

# Install transformers and NLP
echo "Installing Hugging Face transformers..."
pip3 install transformers sentence-transformers

# Install browser automation
echo "Installing Playwright..."
pip3 install playwright
echo "Installing Playwright browsers..."
if command -v playwright &> /dev/null; then
    playwright install chromium
else
    echo "⚠️  Playwright command not found. You may need to restart your shell or add to PATH."
fi

# Install async libraries
echo "Installing async HTTP libraries..."
pip3 install aiohttp

# Install API clients (optional - require API keys)
echo "Installing AI API clients..."
pip3 install openai anthropic google-generativeai together

# Install additional ML libraries
echo "Installing additional ML libraries..."
pip3 install pandas matplotlib seaborn plotly

# Install image processing libraries
echo "Installing advanced image processing..."
pip3 install imageio imageio-ffmpeg

# Verify installation
echo "Verifying installation..."
python3 -c "
import sys
installed_packages = []
failed_packages = []

# Test core packages
packages_to_test = [
    ('torch', 'PyTorch'),
    ('cv2', 'OpenCV'),
    ('PIL', 'Pillow'),
    ('sklearn', 'scikit-learn'),
    ('transformers', 'Transformers'),
    ('requests', 'Requests'),
    ('bs4', 'BeautifulSoup4'),
    ('numpy', 'NumPy')
]

for module_name, display_name in packages_to_test:
    try:
        module = __import__(module_name)
        version = getattr(module, '__version__', 'unknown')
        installed_packages.append(f'{display_name}: {version}')
        print(f'✓ {display_name} version: {version}')
    except ImportError:
        failed_packages.append(display_name)
        print(f'✗ {display_name} not found')

# Test Playwright separately
try:
    import playwright
    installed_packages.append(f'Playwright: {playwright.__version__}')
    print(f'✓ Playwright version: {playwright.__version__}')
except ImportError:
    failed_packages.append('Playwright')
    print('✗ Playwright not found')

print(f'\n📊 Summary: {len(installed_packages)} packages installed, {len(failed_packages)} failed')

if failed_packages:
    print(f'⚠️  Failed packages: {", ".join(failed_packages)}')
    print('You may need to install these manually.')
else:
    print('🎉 All core dependencies installed successfully!')
"

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "1. Get API keys for:"
echo "   - OpenAI (GPT-4V): https://platform.openai.com/api-keys"
echo "   - Anthropic (Claude): https://console.anthropic.com/"
echo "   - Google AI (Gemini): https://makersuite.google.com/app/apikey"
echo "   - Together AI: https://api.together.xyz/"
echo ""
echo "2. Set environment variables or update the script with your API keys"
echo ""
echo "3. Run the advanced analysis script"
echo ""
echo "💡 Troubleshooting tips:"
echo "   - If OpenCV failed, try: pip3 install opencv-python-headless"
echo "   - If Playwright browsers didn't install, run: playwright install chromium"
echo "   - For permission issues, try adding --user flag to pip commands"