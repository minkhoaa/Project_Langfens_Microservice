#!/usr/bin/env python3
"""Fix script for 1500-non-driving-vehicle-competition-driverless-vehicle-competition (Listening)"""
import json
import re
from pathlib import Path

# Paths
DATA_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data")
SOURCE = "mini-ielts"
ITEM_ID = "1500-non-driving-vehicle-competition-driverless-vehicle-competition"
json_path = DATA_DIR / "normalized" / SOURCE / f"{ITEM_ID}.json"

# Load data
with open(json_path) as f:
    data = json.load(f)

# === FIX 1: Replace passage with actual listening notes ===
passage_md = """# Driverless Vehicle Competition - Listening Notes

## Questions 1-3: Complete the sentences

**Driverless vehicle competition**

1. Undergraduates from both the engineering school and the _______ department can definitely take part in the project.

2. The automated vehicles will have to avoid obstacles such as _______ .

3. The tutor mentions one vehicle which used technology such as _______ , lasers, and laptops to measure its surroundings.

---

## Questions 4-6: Multiple Choice

4. The purpose of holding the race is to
   - A. Interest students in careers in industry.
   - B. Help provide finance for universities.
   - C. Find useful new design features.

5. The tutor says success will depend on
   - A. The software design.
   - B. Good, solid construction.
   - C. Sophisticated mechanisms.

6. This year's competitors were surprised that the vehicles
   - A. Were so easy to design.
   - B. Were as successful as they were.
   - C. Took such a short time to construct.

---

## Questions 7-10: Complete the table

**Schedule**

| Time | Activity |
|------|----------|
| Early May | Introductory _______ (7) about the project |
| Late May | Essay giving information about relevant _______ (8) and experience |
| June | Visit to a factory |
| September | Workshop: discuss _______ (9), learn to use design package |
| December | _______ (10) presentation |"""

data['sections'][0]['passage_md'] = passage_md

# === FIX 2: Update instruction_md ===
data['sections'][0]['instruction_md'] = """**Questions 1-3:**

Complete the sentences below.

Write **NO MORE THAN TWO WORDS** for each answer.

---

**Questions 4-6:**

Choose the correct letter, **A**, **B** or **C**.

---

**Questions 7-10:**

Complete the table below.

Write **ONE WORD ONLY** for each answer."""

# === FIX 3: Fix Q1-Q3 prompts (remove leading numbers) ===
q1_fix = "Undergraduates from both the engineering school and the _______ department can definitely take part in the project."
q2_fix = "The automated vehicles will have to avoid obstacles such as _______ ."
q3_fix = "The tutor mentions one vehicle which used technology such as _______ , lasers, and laptops to measure its surroundings."

# === FIX 4: Fix Q4-Q6 prompts and options ===
q4_prompt = "The purpose of holding the race is to"
q4_options = [
    {"label": "A", "text": "Interest students in careers in industry.", "is_correct": False},
    {"label": "B", "text": "Help provide finance for universities.", "is_correct": False},
    {"label": "C", "text": "Find useful new design features.", "is_correct": True}
]

q5_prompt = "The tutor says success will depend on"
q5_options = [
    {"label": "A", "text": "The software design.", "is_correct": True},
    {"label": "B", "text": "Good, solid construction.", "is_correct": False},
    {"label": "C", "text": "Sophisticated mechanisms.", "is_correct": False}
]

q6_prompt = "This year's competitors were surprised that the vehicles"
q6_options = [
    {"label": "A", "text": "Were so easy to design.", "is_correct": False},
    {"label": "B", "text": "Were as successful as they were.", "is_correct": True},
    {"label": "C", "text": "Took such a short time to construct.", "is_correct": False}
]

# === FIX 5: Fix Q7-Q10 prompts ===
q7_prompt = "Early May: Introductory _______ about the project"
q8_prompt = "Late May: Essay giving information about relevant _______ and experience"
q9_prompt = "September Workshop: discuss _______"
q10_prompt = "December: _______ presentation"

# Apply fixes
for q in data['questions']:
    if q['idx'] == 1:
        q['prompt_md'] = q1_fix
    elif q['idx'] == 2:
        q['prompt_md'] = q2_fix
    elif q['idx'] == 3:
        q['prompt_md'] = q3_fix
    elif q['idx'] == 4:
        q['prompt_md'] = q4_prompt
        q['options'] = q4_options
        q['correct_answers'] = ["C"]
    elif q['idx'] == 5:
        q['prompt_md'] = q5_prompt
        q['options'] = q5_options
        q['correct_answers'] = ["A"]
    elif q['idx'] == 6:
        q['prompt_md'] = q6_prompt
        q['options'] = q6_options
        q['correct_answers'] = ["B"]
    elif q['idx'] == 7:
        q['prompt_md'] = q7_prompt
    elif q['idx'] == 8:
        q['prompt_md'] = q8_prompt
    elif q['idx'] == 9:
        q['prompt_md'] = q9_prompt
    elif q['idx'] == 10:
        q['prompt_md'] = q10_prompt

# Save
with open(json_path, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ Fixed {json_path}")
print("  - Replaced passage with actual listening notes")
print("  - Updated instruction_md")
print("  - Fixed Q1-Q3 prompts (removed leading numbers)")
print("  - Fixed Q4-Q6 prompts and options")
print("  - Fixed Q7-Q10 prompts")
