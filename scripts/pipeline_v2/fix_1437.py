#!/usr/bin/env python3
"""Fix script for 1437-an-important-language-development"""
import json
import re
from pathlib import Path

# Paths
DATA_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data")
SOURCE = "mini-ielts"
ITEM_ID = "1437-an-important-language-development"
json_path = DATA_DIR / "normalized" / SOURCE / f"{ITEM_ID}.json"

# Load data
with open(json_path) as f:
    data = json.load(f)

# === FIX 1: Fix Q4 prompt (missing 'A' prefix) ===
for q in data['questions']:
    if q['idx'] == 4:
        q['prompt_md'] = "A number of languages adopted cuneiform."
        print(f"Fixed Q4 prompt: {q['prompt_md']}")

# === FIX 2: Fix paragraph labels (ensure newline after) ===
passage = data['sections'][0]['passage_md']

# Pattern: **Paragraph X.** followed by text without newline
# Should be: **Paragraph X.**\n\nText
def fix_paragraph_newlines(text):
    # Ensure double newline after paragraph labels
    pattern = r'(\*\*Paragraph [A-Z]\.\*\*)(\s*)(?!\n\n)'
    return re.sub(pattern, r'\1\n\n', text)

new_passage = fix_paragraph_newlines(passage)
if new_passage != passage:
    print("Fixed paragraph newlines in passage")
    data['sections'][0]['passage_md'] = new_passage

# Save
with open(json_path, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ Fixed {json_path}")
