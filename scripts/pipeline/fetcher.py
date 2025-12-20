#!/usr/bin/env python3
"""
Stage 1: Fetcher
Fetches raw HTML from IELTS exam URLs and saves to disk.
"""
import json
import re
import requests
from datetime import datetime
from pathlib import Path
from typing import Optional
from urllib.parse import urlparse

from config import RAW_DIR, REQUEST_HEADERS, REQUEST_TIMEOUT, SOURCES, get_logger

logger = get_logger(__name__)


def identify_source(url: str) -> Optional[str]:
    """Identify which source the URL belongs to."""
    for source_name, source_config in SOURCES.items():
        if source_config['domain'] in url:
            return source_name
    return None


def extract_id(url: str, source: str) -> str:
    """Extract unique ID from URL."""
    pattern = SOURCES[source]['url_pattern']
    match = re.search(pattern, url)
    if match:
        # Return combined groups or first group
        if len(match.groups()) > 1:
            return f"{match.group(1)}-{match.group(2)}"
        return match.group(1)
    # Fallback: use URL path hash
    return urlparse(url).path.replace('/', '-').strip('-')


def fetch_url(url: str) -> dict:
    """
    Fetch raw HTML from URL.
    
    Returns dict with:
        - success: bool
        - html: str (if success)
        - error: str (if failed)
        - metadata: dict
    """
    source = identify_source(url)
    if not source:
        return {
            'success': False,
            'error': f'Unknown source for URL: {url}',
            'metadata': {'url': url}
        }
    
    item_id = extract_id(url, source)
    
    metadata = {
        'url': url,
        'source': source,
        'item_id': item_id,
        'fetched_at': datetime.now().isoformat(),
    }
    
    try:
        logger.info(f"Fetching: {url}")
        response = requests.get(url, headers=REQUEST_HEADERS, timeout=REQUEST_TIMEOUT)
        response.raise_for_status()
        
        metadata['status_code'] = response.status_code
        metadata['content_length'] = len(response.text)
        
        return {
            'success': True,
            'html': response.text,
            'metadata': metadata
        }
        
    except requests.RequestException as e:
        logger.error(f"Fetch failed: {e}")
        metadata['error'] = str(e)
        return {
            'success': False,
            'error': str(e),
            'metadata': metadata
        }


def save_raw(result: dict) -> Optional[Path]:
    """Save raw HTML and metadata to disk."""
    if not result['success']:
        logger.error(f"Cannot save failed fetch: {result.get('error')}")
        return None
    
    metadata = result['metadata']
    source = metadata['source']
    item_id = metadata['item_id']
    
    # Create source directory
    source_dir = RAW_DIR / source
    source_dir.mkdir(parents=True, exist_ok=True)
    
    # Save HTML
    html_path = source_dir / f"{item_id}.html"
    html_path.write_text(result['html'], encoding='utf-8')
    
    # Save metadata
    meta_path = source_dir / f"{item_id}.meta.json"
    meta_path.write_text(json.dumps(metadata, indent=2), encoding='utf-8')
    
    logger.info(f"Saved: {html_path}")
    return html_path


def fetch_and_save(url: str) -> Optional[Path]:
    """Fetch URL and save to raw directory."""
    result = fetch_url(url)
    return save_raw(result)


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python fetcher.py <URL>")
        sys.exit(1)
    
    url = sys.argv[1]
    path = fetch_and_save(url)
    if path:
        print(f"✓ Saved to: {path}")
    else:
        print("✗ Fetch failed")
        sys.exit(1)
