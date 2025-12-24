#!/usr/bin/env python3
"""Fix script for 1531-the-ecological-importance-of-bees"""
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

# === FIX 1: Populate MATCHING_HEADING options (Q1-Q5) ===
headings_list = [
    "Parallels between bee and human activities",
    "An evolutionary turning point",
    "A lack of total co-operation",
    "The preservation of individual plant species",
    "The commercial value of bees",
    "The structure of flowering plants",
    "The pursuit of self-interest",
    "The need for further research"
]
# Roman numerals: i, ii, iii, iv, v, vi, vii, viii
roman_numerals = ["i", "ii", "iii", "iv", "v", "vi", "vii", "viii"]

# Build options list
heading_options = []
for idx, text in enumerate(headings_list):
    value = roman_numerals[idx]
    heading_options.append({
        "value": value,
        "label": f"{value} {text}",
        "is_correct": False # will be set per question
    })

# Correct answers for Q1-Q5
# Q1 (Para A) -> ii
# Q2 (Para B) -> v
# Example (Para C) -> vii
# Q3 (Para D) -> i
# Q4 (Para E) -> iv
# Q5 (Para F) -> viii
correct_answers_map = {
    1: "ii",
    2: "v",
    3: "i",
    4: "iv",
    5: "viii"
}

# Apply to Q1-Q5
for q in data['questions']:
    if q['idx'] in range(1, 6):
        # Set type back to MATCHING_HEADING if repair changed it
        q['type'] = "MATCHING_HEADING"
        # Set options (deep copy)
        import copy
        q['options'] = copy.deepcopy(heading_options)
        # Set correct
        correct_val = correct_answers_map[q['idx']]
        for opt in q['options']:
            if opt['value'] == correct_val:
                opt['is_correct'] = True
        q['correct_answers'] = [correct_val]
        # Clean prompt
        q['prompt_md'] = q['prompt_md'].replace("Paragraph ", "Paragraph ")

# === FIX 2: Remove leading numbers from Q6-Q12 prompts ===
for q in data['questions']:
    if q['idx'] in range(6, 13):
        # Remove leading "6. " patterns
        q['prompt_md'] = re.sub(r'^\d+\.\s*', '', q['prompt_md'])


# === FIX 3: Fix Q13 options ===
q13_options = [
    {"value": "A", "label": "A. The Ecological Importance of Bees", "is_correct": True},
    {"value": "B", "label": "B. The Evolutionary History of Bees", "is_correct": False},
    {"value": "C", "label": "C. The Social Behaviour of Bees", "is_correct": False},
    {"value": "D", "label": "D. The Geographical Distribution of Bees", "is_correct": False}
]

for q in data['questions']:
    if q['idx'] == 13:
        q['type'] = "MULTIPLE_CHOICE_SINGLE"
        q['options'] = q13_options
        q['correct_answers'] = ["A"]

# === FIX 4: Instruction MD ===
data['sections'][0]['instruction_md'] = """**Questions 1-5:**

The Reading Passage has seven paragraphs, **A-G**.

Choose the correct heading for paragraphs **A, B, D, E** and **F** from the list of headings below.

Write the correct number, **i-viii**.

**List of Headings**
- **i** Parallels between bee and human activities
- **ii** An evolutionary turning point
- **iii** A lack of total co-operation
- **iv** The preservation of individual plant species
- **v** The commercial value of bees
- **vi** The structure of flowering plants
- **vii** The pursuit of self-interest
- **viii** The need for further research

---

**Questions 6-12:**

Complete the sentences below.

Choose **NO MORE THAN TWO WORDS AND/OR A NUMBER** from the passage for each answer.

---

**Question 13:**

Choose the correct letter, **A, B, C** or **D**.

Which is the best title for Reading Passage?"""

# Save
with open(json_path, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ Fixed {json_path}")
print("  - Populated Q1-Q5 MATCHING_HEADING options (i-viii)")
print("  - Fixed Q6-Q12 leading numbers in prompts")
print("  - Restored Q13 options A-D")
print("  - Updated instruction_md")
