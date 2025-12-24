#!/usr/bin/env python3
"""Fix script for 1531-the-ecological-importance-of-bees: Deduplicate paragraph headers"""
import json
import re
from pathlib import Path

# Paths
DATA_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data")
SOURCE = "mini-ielts"
ITEM_ID = "1531-the-ecological-importance-of-bees"
json_path = DATA_DIR / "normalized" / SOURCE / f"{ITEM_ID}.json"

# Load data
with open(json_path) as f:
    data = json.load(f)

passage = data['sections'][0]['passage_md']

# Regex to find duplicate headers: "**Paragraph X.**\n**Paragraph X.**"
# We match: (**Paragraph [A-Z]\.**)\n\1
# And replace with \1
# Note: The existing format seems to be "**Paragraph A.**" -> bolded.
# Let's match exact pattern seen in JSON: "**Paragraph A.**\n**Paragraph A.**"

def dedup_headers(text):
    # Pattern: Look for repeat lines
    # (\*\*Paragraph [A-Z]\.\*\*\n)\1
    pattern = r'(\*\*Paragraph [A-Z]\.\*\*\n)\1'
    return re.sub(pattern, r'\1', text)

new_passage = dedup_headers(passage)

# Also removing the plain "Paragraph A.\nParagraph A." if present without bolding, 
# but the JSON showed bolding. Just in case, let's also fix non-bold if needed, 
# but rely on what we saw: "**Paragraph A.**\n**Paragraph A.**"

if new_passage != passage:
    print("Found and replaced duplicate headers.")
    data['sections'][0]['passage_md'] = new_passage
    
    # Save
    with open(json_path, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"✅ Fixed duplicates in {json_path}")
else:
    print("No duplicates found matching pattern.")

