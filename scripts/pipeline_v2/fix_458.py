#!/usr/bin/env python3
"""Fix script for 458-the-work-placement (Listening)"""
import json
from pathlib import Path

# Paths
DATA_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data")
SOURCE = "mini-ielts"
ITEM_ID = "458-the-work-placement"
json_path = DATA_DIR / "normalized" / SOURCE / f"{ITEM_ID}.json"

# Load data
with open(json_path) as f:
    data = json.load(f)

# === FIX 1: Replace passage with actual listening notes ===
passage_md = """# The Work Placement - Listening Notes

## Questions 1-2: Choose TWO letters, A-E

Which **TWO** skills did Laura improve as a result of her work placement?

- A. communication
- B. design
- C. IT
- D. marketing
- E. organisation

---

## Questions 3-4: Choose TWO letters, A-E

Which **TWO** immediate benefits did the company get from Laura's work placement?

- A. updates for its software
- B. cost savings
- C. an improved image
- D. new clients
- E. a growth in sales

---

## Questions 5-10: Matching

What source of information should Tim use at each of the following stages of the work placement?

**Sources of information:**
- A. company manager
- B. company's personnel department
- C. personal tutor
- D. psychology department
- E. mentor
- F. university careers officer
- G. internet

**Stages of the work placement procedure:**
- 5. obtaining booklet
- 6. discussing options
- 7. getting updates
- 8. responding to invitation for interview
- 9. informing about outcome of interview
- 10. requesting a reference"""

data['sections'][0]['passage_md'] = passage_md

# === FIX 2: Update instruction_md ===
data['sections'][0]['instruction_md'] = """**Questions 1-2:**

Choose **TWO** letters, **A-E**.

Which **TWO** skills did Laura improve as a result of her work placement?

---

**Questions 3-4:**

Choose **TWO** letters, **A-E**.

Which **TWO** immediate benefits did the company get from Laura's work placement?

---

**Questions 5-10:**

What source of information should Tim use at each of the following stages of the work placement?

Choose **SIX** answers from the box and write the correct letter, **A-G**."""

# === FIX 3: Build complete questions array ===
# Q1-2: Choose TWO (A, E) - Skills Laura improved
q1_2_options = [
    {"label": "A", "text": "communication", "is_correct": True},
    {"label": "B", "text": "design", "is_correct": False},
    {"label": "C", "text": "IT", "is_correct": False},
    {"label": "D", "text": "marketing", "is_correct": False},
    {"label": "E", "text": "organisation", "is_correct": True}
]

# Q3-4: Choose TWO (B, C) - Benefits company got
q3_4_options = [
    {"label": "A", "text": "updates for its software", "is_correct": False},
    {"label": "B", "text": "cost savings", "is_correct": True},
    {"label": "C", "text": "an improved image", "is_correct": True},
    {"label": "D", "text": "new clients", "is_correct": False},
    {"label": "E", "text": "a growth in sales", "is_correct": False}
]

# Q5-10: Matching with answers D, F, G, B, E, C
matching_answers = {
    5: ("obtaining booklet", "D"),
    6: ("discussing options", "F"),
    7: ("getting updates", "G"),
    8: ("responding to invitation for interview", "B"),
    9: ("informing about outcome of interview", "E"),
    10: ("requesting a reference", "C")
}

new_questions = []

# Q1 - first of "choose TWO" pair (answer A)
new_questions.append({
    "idx": 1,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which skill did Laura improve as a result of her work placement? (Answer 1 of 2)",
    "options": [
        {"label": "A", "text": "communication", "is_correct": True},
        {"label": "B", "text": "design", "is_correct": False},
        {"label": "C", "text": "IT", "is_correct": False},
        {"label": "D", "text": "marketing", "is_correct": False},
        {"label": "E", "text": "organisation", "is_correct": False}
    ],
    "correct_answers": ["A"]
})

# Q2 - second of "choose TWO" pair (answer E)
new_questions.append({
    "idx": 2,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which skill did Laura improve as a result of her work placement? (Answer 2 of 2)",
    "options": [
        {"label": "A", "text": "communication", "is_correct": False},
        {"label": "B", "text": "design", "is_correct": False},
        {"label": "C", "text": "IT", "is_correct": False},
        {"label": "D", "text": "marketing", "is_correct": False},
        {"label": "E", "text": "organisation", "is_correct": True}
    ],
    "correct_answers": ["E"]
})

# Q3 - first of "choose TWO" pair (answer B)
new_questions.append({
    "idx": 3,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which immediate benefit did the company get from Laura's work placement? (Answer 1 of 2)",
    "options": [
        {"label": "A", "text": "updates for its software", "is_correct": False},
        {"label": "B", "text": "cost savings", "is_correct": True},
        {"label": "C", "text": "an improved image", "is_correct": False},
        {"label": "D", "text": "new clients", "is_correct": False},
        {"label": "E", "text": "a growth in sales", "is_correct": False}
    ],
    "correct_answers": ["B"]
})

# Q4 - second of "choose TWO" pair (answer C)
new_questions.append({
    "idx": 4,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which immediate benefit did the company get from Laura's work placement? (Answer 2 of 2)",
    "options": [
        {"label": "A", "text": "updates for its software", "is_correct": False},
        {"label": "B", "text": "cost savings", "is_correct": False},
        {"label": "C", "text": "an improved image", "is_correct": True},
        {"label": "D", "text": "new clients", "is_correct": False},
        {"label": "E", "text": "a growth in sales", "is_correct": False}
    ],
    "correct_answers": ["C"]
})

# Q5-10: Matching questions
for idx, (prompt, answer) in matching_answers.items():
    new_questions.append({
        "idx": idx,
        "type": "MATCHING_INFORMATION",
        "prompt_md": prompt,
        "options": [],
        "correct_answers": [answer]
    })

data['questions'] = new_questions

# Save
with open(json_path, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ Fixed {json_path}")
print("  - Replaced passage with actual listening notes")
print("  - Updated instruction_md")
print("  - Added Q1-Q4 (Choose TWO as separate MCQ_SINGLE)")
print("  - Fixed Q5-Q10 (Matching)")
print(f"  - Total questions: {len(new_questions)}")
