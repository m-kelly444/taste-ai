from PIL import Image, ImageFilter, ImageEnhance
import numpy as np
from typing import Tuple, List
import io
import base64

def resize_image(image: Image.Image, size: Tuple[int, int] = (224, 224)) -> Image.Image:
    return image.resize(size, Image.Resampling.LANCZOS)

def normalize_image(image: Image.Image) -> Image.Image:
    if image.mode != 'RGB':
        image = image.convert('RGB')
    return image

def extract_dominant_colors(image: Image.Image, num_colors: int = 5) -> List[str]:
    image = image.resize((100, 100))
    result = image.quantize(colors=num_colors)
    palette = result.getpalette()
    
    colors = []
    for i in range(num_colors):
        r = palette[i*3]
        g = palette[i*3 + 1]
        b = palette[i*3 + 2]
        colors.append(f"#{r:02x}{g:02x}{b:02x}")
    
    return colors

def calculate_brightness(image: Image.Image) -> float:
    grayscale = image.convert('L')
    stat = np.array(grayscale)
    return np.mean(stat) / 255.0

def calculate_contrast(image: Image.Image) -> float:
    grayscale = image.convert('L')
    stat = np.array(grayscale)
    return np.std(stat) / 255.0

def image_to_base64(image: Image.Image) -> str:
    buffer = io.BytesIO()
    image.save(buffer, format='PNG')
    img_str = base64.b64encode(buffer.getvalue()).decode()
    return img_str

def base64_to_image(base64_str: str) -> Image.Image:
    img_data = base64.b64decode(base64_str)
    return Image.open(io.BytesIO(img_data))
