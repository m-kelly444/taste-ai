#!/usr/bin/env python3

import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import random

def create_advanced_test_images():
    """Create advanced test images for comprehensive testing"""
    
    os.makedirs('test-images/advanced', exist_ok=True)
    print("📁 Created advanced test images directory")
    
    # Test Image Set 1: Burch Brand Aesthetic
    create_burch_style_images()
    
    # Test Image Set 2: Fashion Photography
    create_fashion_images()
    
    # Test Image Set 3: Commercial Product Images
    create_product_images()
    
    # Test Image Set 4: Trend Analysis Images
    create_trend_images()
    
    print("✅ Advanced test image dataset created!")

def create_burch_style_images():
    """Create images that align with Chris Burch aesthetic"""
    
    # Image 1: Classic Navy & Camel
    img = Image.new('RGB', (600, 400), color='#f5f5dc')  # Cream background
    draw = ImageDraw.Draw(img)
    
    # Navy accent
    draw.rectangle([50, 50, 250, 200], fill='#1e3a5f', outline='#8B4513', width=3)
    # Camel leather texture effect
    draw.ellipse([300, 100, 500, 300], fill='#C19A6B', outline='#8B4513', width=2)
    
    # Gold hardware accent
    draw.ellipse([350, 150, 380, 180], fill='#FFD700', outline='#B8860B', width=2)
    
    img.save('test-images/advanced/burch_classic_navy_camel.jpg', 'JPEG', quality=95)
    print("✅ Created Burch classic navy & camel")
    
    # Image 2: Minimalist Luxury
    img = Image.new('RGB', (600, 400), color='#faf8f5')  # Off-white
    draw = ImageDraw.Draw(img)
    
    # Simple geometric shapes in muted tones
    draw.rectangle([100, 150, 500, 250], fill='#d4c4a8', outline='#a0956b', width=1)
    draw.line([150, 100, 450, 300], fill='#8d7053', width=2)
    
    # Subtle texture
    for i in range(0, 600, 20):
        for j in range(0, 400, 20):
            if random.random() > 0.8:
                draw.point((i, j), fill='#e8e0d3')
    
    img.save('test-images/advanced/burch_minimalist_luxury.jpg', 'JPEG', quality=95)
    print("✅ Created Burch minimalist luxury")

def create_fashion_images():
    """Create fashion-style images for trend analysis"""
    
    # Image 1: Sustainable Fashion Aesthetic
    img = Image.new('RGB', (500, 600), color='#e8e5d9')  # Natural beige
    draw = ImageDraw.Draw(img)
    
    # Organic shapes representing natural materials
    for i in range(5):
        x = random.randint(50, 450)
        y = random.randint(50, 550)
        r = random.randint(20, 60)
        color = random.choice(['#8fbc8f', '#deb887', '#d2b48c', '#f5deb3'])
        draw.ellipse([x-r, y-r, x+r, y+r], fill=color, outline='#556b2f', width=1)
    
    img.save('test-images/advanced/sustainable_fashion.jpg', 'JPEG', quality=95)
    print("✅ Created sustainable fashion image")
    
    # Image 2: Digital Age Minimalism
    img = Image.new('RGB', (500, 500), color='#ffffff')
    draw = ImageDraw.Draw(img)
    
    # Clean lines and negative space
    draw.rectangle([100, 100, 400, 150], fill='#2c3e50')
    draw.rectangle([200, 200, 250, 400], fill='#34495e')
    draw.ellipse([300, 250, 380, 330], fill='#ecf0f1', outline='#bdc3c7', width=2)
    
    img.save('test-images/advanced/digital_minimalism.jpg', 'JPEG', quality=95)
    print("✅ Created digital minimalism image")

def create_product_images():
    """Create product-style images for commercial analysis"""
    
    # Image 1: Luxury Handbag Style
    img = Image.new('RGB', (400, 500), color='#f8f8f8')
    draw = ImageDraw.Draw(img)
    
    # Handbag silhouette
    draw.ellipse([100, 200, 300, 350], fill='#8B4513', outline='#654321', width=3)
    draw.rectangle([120, 180, 280, 220], fill='#DAA520', outline='#B8860B', width=2)
    
    # Handle
    draw.ellipse([150, 120, 170, 200], fill='none', outline='#8B4513', width=8)
    draw.ellipse([230, 120, 250, 200], fill='none', outline='#8B4513', width=8)
    
    # Hardware details
    draw.ellipse([190, 240, 210, 260], fill='#FFD700', outline='#DAA520', width=1)
    
    img.save('test-images/advanced/luxury_handbag.jpg', 'JPEG', quality=95)
    print("✅ Created luxury handbag image")
    
    # Image 2: Contemporary Accessories
    img = Image.new('RGB', (450, 300), color='#fefefe')
    draw = ImageDraw.Draw(img)
    
    # Watch/jewelry style composition
    draw.ellipse([200, 100, 250, 150], fill='#C0C0C0', outline='#696969', width=2)
    draw.ellipse([210, 110, 240, 140], fill='#F5F5F5', outline='#A9A9A9', width=1)
    
    # Strap/band
    draw.rectangle([180, 125, 200, 135], fill='#8B4513')
    draw.rectangle([250, 125, 270, 135], fill='#8B4513')
    
    img.save('test-images/advanced/contemporary_accessories.jpg', 'JPEG', quality=95)
    print("✅ Created contemporary accessories image")

def create_trend_images():
    """Create images representing different trend categories"""
    
    # Image 1: Maximalist vs Minimalist
    img = Image.new('RGB', (600, 300), color='#ffffff')
    draw = ImageDraw.Draw(img)
    
    # Left side: Maximalist (busy, many elements)
    for i in range(50):
        x = random.randint(0, 290)
        y = random.randint(0, 290)
        r = random.randint(5, 25)
        color = (random.randint(100, 255), random.randint(100, 255), random.randint(100, 255))
        draw.ellipse([x-r, y-r, x+r, y+r], fill=color)
    
    # Right side: Minimalist (clean, simple)
    draw.rectangle([350, 100, 550, 200], fill='#2c3e50')
    draw.ellipse([400, 220, 450, 270], fill='#e74c3c')
    
    img.save('test-images/advanced/maximalist_vs_minimalist.jpg', 'JPEG', quality=95)
    print("✅ Created maximalist vs minimalist comparison")
    
    # Image 2: Color Trend Analysis
    img = Image.new('RGB', (500, 400), color='#ffffff')
    draw = ImageDraw.Draw(img)
    
    # Trending color palette
    trending_colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#f9ca24', '#6c5ce7']
    
    for i, color in enumerate(trending_colors):
        x = 50 + i * 80
        draw.rectangle([x, 100, x + 60, 300], fill=color)
        
        # Add texture/pattern
        for j in range(100, 300, 10):
            if j % 20 == 0:
                draw.line([x, j, x + 60, j], fill='#ffffff', width=1)
    
    img.save('test-images/advanced/color_trend_analysis.jpg', 'JPEG', quality=95)
    print("✅ Created color trend analysis image")

if __name__ == "__main__":
    print("🎨 Advanced Test Image Generator")
    print("===============================")
    create_advanced_test_images()
    
    # List all created files
    all_files = []
    for root, dirs, files in os.walk('test-images'):
        for file in files:
            if file.endswith('.jpg'):
                all_files.append(os.path.join(root, file))
    
    print(f"\n📋 Total test images: {len(all_files)}")
    for file in sorted(all_files):
        print(f"  • {file}")
