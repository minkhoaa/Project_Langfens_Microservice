#!/usr/bin/env python3
"""
Stage 2: Cleaner
Cleans raw HTML and extracts main content.
"""
import json
import re
from bs4 import BeautifulSoup, NavigableString
from pathlib import Path
from typing import Optional

from config import RAW_DIR, CLEANED_DIR, get_logger

logger = get_logger(__name__)


def load_raw(source: str, item_id: str) -> Optional[dict]:
    """Load raw HTML and metadata from disk."""
    source_dir = RAW_DIR / source
    html_path = source_dir / f"{item_id}.html"
    meta_path = source_dir / f"{item_id}.meta.json"
    
    if not html_path.exists():
        logger.error(f"Raw HTML not found: {html_path}")
        return None
    
    html = html_path.read_text(encoding='utf-8')
    metadata = {}
    if meta_path.exists():
        metadata = json.loads(meta_path.read_text(encoding='utf-8'))
    
    return {'html': html, 'metadata': metadata}


def extract_main_content(html: str, source: str) -> str:
    """Extract main content from HTML based on source."""
    soup = BeautifulSoup(html, 'html.parser')
    
    # Remove scripts, styles, nav, footer
    for tag in soup.find_all(['script', 'style', 'nav', 'footer', 'header', 'aside']):
        tag.decompose()
    
    # Find main content container
    if source == 'ielts-mentor':
        main = soup.find('article') or soup.find('div', class_='item-page')
    elif source == 'ielts-writing':
        main = soup.find('div', class_='content') or soup.find('main')
    else:
        main = soup.find('main') or soup.find('article')
    
    if not main:
        main = soup.body or soup
    
    return main


def get_text_preserving_structure(element) -> str:
    """Extract text while preserving paragraph structure."""
    parts = []
    
    for child in element.children:
        if isinstance(child, NavigableString):
            text = str(child).strip()
            if text:
                parts.append(text)
        elif child.name in ['p', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            text = child.get_text(separator=' ', strip=True)
            if text:
                parts.append(f"\n\n{text}")
        elif child.name in ['br']:
            parts.append('\n')
        elif child.name in ['ul', 'ol']:
            for li in child.find_all('li', recursive=False):
                text = li.get_text(separator=' ', strip=True)
                if text:
                    parts.append(f"\n- {text}")
        elif child.name in ['strong', 'b', 'em', 'i', 'span', 'a']:
            text = child.get_text(separator=' ', strip=True)
            if text:
                parts.append(text)
        elif hasattr(child, 'children'):
            parts.append(get_text_preserving_structure(child))
    
    return ' '.join(parts)


def clean_text(text: str) -> str:
    """Clean and normalize text."""
    # Normalize whitespace
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    # Remove common noise patterns
    noise_patterns = [
        r'Last Updated:.*?\n',
        r'Written by.*?\n',
        r'Hits:.*?\n',
        r'Rating:.*?\n',
        r'Click the button.*?\n',
        r'Show/Hide.*?\n',
        r'IELTS Mentor.*?\n',
        r'Share this page.*',
        r'You should spend about \d+ minutes on this task.*?answer sheet\.',
    ]
    for pattern in noise_patterns:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE)
    
    return text.strip()


def clean_html(source: str, item_id: str) -> Optional[dict]:
    """
    Clean raw HTML and extract main content.
    
    Returns dict with:
        - success: bool
        - text: str (cleaned text)
        - metadata: dict
    """
    raw = load_raw(source, item_id)
    if not raw:
        return {'success': False, 'error': 'Raw data not found'}
    
    logger.info(f"Cleaning: {source}/{item_id}")
    
    main_element = extract_main_content(raw['html'], source)
    
    # Get text with structure
    text = main_element.get_text(separator='\n', strip=True)
    text = clean_text(text)
    
    metadata = raw['metadata'].copy()
    metadata['cleaned_at'] = __import__('datetime').datetime.now().isoformat()
    metadata['text_length'] = len(text)
    
    return {
        'success': True,
        'text': text,
        'metadata': metadata
    }


def save_cleaned(result: dict) -> Optional[Path]:
    """Save cleaned text to disk."""
    if not result['success']:
        return None
    
    metadata = result['metadata']
    source = metadata['source']
    item_id = metadata['item_id']
    
    # Create source directory
    source_dir = CLEANED_DIR / source
    source_dir.mkdir(parents=True, exist_ok=True)
    
    # Save text
    text_path = source_dir / f"{item_id}.txt"
    text_path.write_text(result['text'], encoding='utf-8')
    
    # Save metadata
    meta_path = source_dir / f"{item_id}.meta.json"
    meta_path.write_text(json.dumps(metadata, indent=2), encoding='utf-8')
    
    logger.info(f"Saved cleaned: {text_path}")
    return text_path


def clean_and_save(source: str, item_id: str) -> Optional[Path]:
    """Clean raw HTML and save cleaned text."""
    result = clean_html(source, item_id)
    return save_cleaned(result)


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python cleaner.py <source> <item_id>")
        print("Example: python cleaner.py ielts-mentor 3721-marine-ecosystems")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    path = clean_and_save(source, item_id)
    if path:
        print(f"✓ Saved to: {path}")
    else:
        print("✗ Clean failed")
        sys.exit(1)
