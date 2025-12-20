#!/usr/bin/env python3
"""
IELTS Pipeline Configuration
"""
from pathlib import Path

# Base paths
PROJECT_ROOT = Path(__file__).parent.parent.parent
SCRIPTS_DIR = PROJECT_ROOT / "scripts" / "pipeline"
DATA_DIR = PROJECT_ROOT / "data"
SEEDS_DIR = PROJECT_ROOT / "deploy" / "seeds"

# Stage output directories
RAW_DIR = DATA_DIR / "raw"
CLEANED_DIR = DATA_DIR / "cleaned"
PARSED_DIR = DATA_DIR / "parsed"
NORMALIZED_DIR = DATA_DIR / "normalized"
OUTPUT_DIR = DATA_DIR / "output"
QUARANTINE_DIR = DATA_DIR / "quarantine"
LOGS_DIR = DATA_DIR / "logs"

# Ensure directories exist
for d in [RAW_DIR, CLEANED_DIR, PARSED_DIR, NORMALIZED_DIR, OUTPUT_DIR, QUARANTINE_DIR, LOGS_DIR]:
    d.mkdir(parents=True, exist_ok=True)

# HTTP settings
REQUEST_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
}
REQUEST_TIMEOUT = 30

# Supported sources
SOURCES = {
    'ielts-mentor': {
        'domain': 'ielts-mentor.com',
        'url_pattern': r'ielts-mentor\.com/reading-sample/.*/(\d+)-(.+)',
    },
    'ielts-writing': {
        'domain': 'ielts-writing.info',
        'url_pattern': r'ielts-writing\.info/EXAM/ielts_reading/(\d+)',
    }
}

# Question types
QUESTION_TYPES = [
    'TRUE_FALSE_NOT_GIVEN',
    'YES_NO_NOT_GIVEN',
    'MULTIPLE_CHOICE_SINGLE',
    'MULTIPLE_CHOICE_MULTIPLE',
    'MATCHING_HEADING',
    'MATCHING_INFORMATION',
    'MATCHING_FEATURES',
    'SUMMARY_COMPLETION',
    'SHORT_ANSWER',
    'SENTENCE_COMPLETION',
]

# Logging
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOGS_DIR / "pipeline.log"),
        logging.StreamHandler()
    ]
)

def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
