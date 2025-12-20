#!/usr/bin/env python3
"""
Stage 2: Extract
Extracts passages, questions, and answers from raw HTML.
IMPORTS extraction logic from old crawlers (ieltsmentor, ieltswriting).
"""
import json
import re
import importlib.util
from bs4 import BeautifulSoup
from pathlib import Path
from typing import Optional

from config import RAW_DIR, EXTRACTED_DIR, get_logger

logger = get_logger(__name__)

# Import old crawler modules
def load_crawler_module(name: str, filename: str):
    """Load old crawler module dynamically."""
    try:
        spec = importlib.util.spec_from_file_location(
            name,
            Path(__file__).parent.parent / "crawler" / filename
        )
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module
    except Exception as e:
        logger.error(f"Failed to import {filename}: {e}")
        return None

crawler_ieltsmentor = load_crawler_module("crawler_ieltsmentor", "crawler-ieltsmentor.py")
crawler_ieltswriting = load_crawler_module("crawler_ieltswriting", "crawler-ieltswriting.py")

if crawler_ieltsmentor:
    logger.info("Successfully imported crawler-ieltsmentor.py")
if crawler_ieltswriting:
    logger.info("Successfully imported crawler-ieltswriting.py")


def load_raw(source: str, item_id: str) -> Optional[dict]:
    """Load raw HTML from disk."""
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
    
    return {'html': html, 'metadata': metadata, 'source': source, 'item_id': item_id}


def extract_ielts_mentor(html: str, url: str) -> dict:
    """
    Extract data using ielts-mentor crawler functions.
    Matches the EXACT flow from old crawler main block.
    """
    c = crawler_ieltsmentor  # alias
    soup = BeautifulSoup(html, 'html.parser')
    
    # Use OLD CRAWLER functions - exact same flow as main block
    title = c.extract_title(soup)
    exam_id = c.extract_exam_id(url)
    passages = c.extract_passages(soup)
    answers = c.extract_answers(soup)
    question_texts = c.extract_question_texts(soup)
    heading_options = c.extract_heading_options(soup)
    
    # extract_questions takes: soup, answers, question_texts, heading_options
    questions = c.extract_questions(soup, answers, question_texts, heading_options)
    
    return {
        'title': title,
        'exam_id': exam_id,
        'passages': passages,
        'questions': questions,
        'answers': answers,
        'heading_options': heading_options,
    }


def extract_ielts_writing(html: str, url: str) -> dict:
    """
    Extract data using ielts-writing crawler functions.
    """
    c = crawler_ieltswriting  # alias
    soup = BeautifulSoup(html, 'html.parser')
    
    # Use OLD CRAWLER functions
    title = c.extract_title(soup)
    exam_id = c.extract_exam_id(url)
    passages = c.extract_passages(soup)
    answers = c.extract_answers(soup)
    question_texts = c.extract_question_texts(soup)
    heading_options = c.extract_heading_options(soup)
    
    questions = c.extract_questions(soup, answers, question_texts, heading_options)
    
    return {
        'title': title,
        'exam_id': exam_id,
        'passages': passages,
        'questions': questions,
        'answers': answers,
        'heading_options': heading_options,
    }


def extract(source: str, item_id: str) -> Optional[dict]:
    """
    Extract structured data from raw HTML.
    Uses OLD CRAWLER extraction functions.
    """
    raw = load_raw(source, item_id)
    if not raw:
        return None
    
    logger.info(f"Extracting: {source}/{item_id}")
    
    url = raw['metadata'].get('url', '')
    html = raw['html']
    
    if source == 'ielts-mentor':
        extracted = extract_ielts_mentor(html, url)
    elif source == 'ielts-writing':
        extracted = extract_ielts_writing(html, url)
    else:
        logger.error(f"Unknown source: {source}")
        return None
    
    # Add metadata
    extracted['source'] = source
    extracted['item_id'] = item_id
    extracted['url'] = url
    
    return extracted


def save_extracted(data: dict) -> Optional[Path]:
    """Save extracted data to disk."""
    source = data['source']
    item_id = data['item_id']
    
    source_dir = EXTRACTED_DIR / source
    source_dir.mkdir(parents=True, exist_ok=True)
    
    output_path = source_dir / f"{item_id}.json"
    output_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
    
    logger.info(f"Saved extracted: {output_path}")
    return output_path


def extract_and_save(source: str, item_id: str) -> Optional[dict]:
    """Extract data and save to disk. Returns extracted data."""
    data = extract(source, item_id)
    if data:
        save_extracted(data)
    return data


# CLI
if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python extract.py <source> <item_id>")
        sys.exit(1)
    
    source, item_id = sys.argv[1], sys.argv[2]
    result = extract_and_save(source, item_id)
    if result:
        print(f"✓ Extracted: {len(result.get('questions', []))} questions")
    else:
        print("✗ Extraction failed")
        sys.exit(1)
