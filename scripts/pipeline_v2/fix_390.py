#!/usr/bin/env python3
"""Fix script for 390-new-staff-at-theatre (Listening)"""
import json
from pathlib import Path

# Paths
DATA_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data")
SOURCE = "mini-ielts"
ITEM_ID = "390-new-staff-at-theatre"
json_path = DATA_DIR / "normalized" / SOURCE / f"{ITEM_ID}.json"

# Load data
with open(json_path) as f:
    data = json.load(f)

# === FIX 1: Replace passage with actual listening notes ===
passage_md = """# New Staff at Theatre - Listening Notes

## Questions 1-2: Choose TWO letters, A-E

Which **TWO** changes have been made so far during the refurbishment of the theatre?

- A. Some rooms now have a different use.
- B. A different type of seating has been installed.
- C. An elevator has been installed.
- D. The outside of the building has been repaired.
- E. Extra seats have been added.

---

## Questions 3-4: Choose TWO letters, A-E

Which **TWO** facilities does the theatre currently offer to the public?

- A. rooms for hire
- B. backstage tours
- C. hire of costumes
- D. a bookshop
- E. a cafe

---

## Questions 5-6: Choose TWO letters, A-E

Which **TWO** workshops does the theatre currently offer?

- A. sound
- B. acting
- C. making puppets
- D. make-up
- E. lighting

---

## Questions 7-10: Label the plan

**Ground floor plan of theatre**

Write the correct letter, **A-G**, next to Questions 7-10.

- 7. box office
- 8. theatre manager's office
- 9. lighting box
- 10. artistic director's office"""

data['sections'][0]['passage_md'] = passage_md

# === FIX 2: Update instruction_md ===
data['sections'][0]['instruction_md'] = """**Questions 1-2:**

Choose **TWO** letters, **A-E**.

Which **TWO** changes have been made so far during the refurbishment of the theatre?

---

**Questions 3-4:**

Choose **TWO** letters, **A-E**.

Which **TWO** facilities does the theatre currently offer to the public?

---

**Questions 5-6:**

Choose **TWO** letters, **A-E**.

Which **TWO** workshops does the theatre currently offer?

---

**Questions 7-10:**

Label the plan below. Write the correct letter, **A-G**."""

# === FIX 3: Build complete questions array ===
# Answers from source:
# Q1-2: A,B (changes during refurbishment)
# Q3-4: B,D (facilities offered)
# Q5-6: C,E (workshops offered)
# Q7-10: G,D,B,F (matching)

new_questions = []

# Q1-2: Choose TWO (A, B) - Changes during refurbishment
q1_2_opts = [
    {"label": "A", "text": "Some rooms now have a different use.", "is_correct": True},
    {"label": "B", "text": "A different type of seating has been installed.", "is_correct": True},
    {"label": "C", "text": "An elevator has been installed.", "is_correct": False},
    {"label": "D", "text": "The outside of the building has been repaired.", "is_correct": False},
    {"label": "E", "text": "Extra seats have been added.", "is_correct": False}
]

new_questions.append({
    "idx": 1,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which change has been made during the refurbishment of the theatre? (Answer 1 of 2)",
    "options": [
        {"label": "A", "text": "Some rooms now have a different use.", "is_correct": True},
        {"label": "B", "text": "A different type of seating has been installed.", "is_correct": False},
        {"label": "C", "text": "An elevator has been installed.", "is_correct": False},
        {"label": "D", "text": "The outside of the building has been repaired.", "is_correct": False},
        {"label": "E", "text": "Extra seats have been added.", "is_correct": False}
    ],
    "correct_answers": ["A"]
})

new_questions.append({
    "idx": 2,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which change has been made during the refurbishment of the theatre? (Answer 2 of 2)",
    "options": [
        {"label": "A", "text": "Some rooms now have a different use.", "is_correct": False},
        {"label": "B", "text": "A different type of seating has been installed.", "is_correct": True},
        {"label": "C", "text": "An elevator has been installed.", "is_correct": False},
        {"label": "D", "text": "The outside of the building has been repaired.", "is_correct": False},
        {"label": "E", "text": "Extra seats have been added.", "is_correct": False}
    ],
    "correct_answers": ["B"]
})

# Q3-4: Choose TWO (B, D) - Facilities offered
new_questions.append({
    "idx": 3,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which facility does the theatre currently offer to the public? (Answer 1 of 2)",
    "options": [
        {"label": "A", "text": "rooms for hire", "is_correct": False},
        {"label": "B", "text": "backstage tours", "is_correct": True},
        {"label": "C", "text": "hire of costumes", "is_correct": False},
        {"label": "D", "text": "a bookshop", "is_correct": False},
        {"label": "E", "text": "a cafe", "is_correct": False}
    ],
    "correct_answers": ["B"]
})

new_questions.append({
    "idx": 4,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which facility does the theatre currently offer to the public? (Answer 2 of 2)",
    "options": [
        {"label": "A", "text": "rooms for hire", "is_correct": False},
        {"label": "B", "text": "backstage tours", "is_correct": False},
        {"label": "C", "text": "hire of costumes", "is_correct": False},
        {"label": "D", "text": "a bookshop", "is_correct": True},
        {"label": "E", "text": "a cafe", "is_correct": False}
    ],
    "correct_answers": ["D"]
})

# Q5-6: Choose TWO (C, E) - Workshops offered
new_questions.append({
    "idx": 5,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which workshop does the theatre currently offer? (Answer 1 of 2)",
    "options": [
        {"label": "A", "text": "sound", "is_correct": False},
        {"label": "B", "text": "acting", "is_correct": False},
        {"label": "C", "text": "making puppets", "is_correct": True},
        {"label": "D", "text": "make-up", "is_correct": False},
        {"label": "E", "text": "lighting", "is_correct": False}
    ],
    "correct_answers": ["C"]
})

new_questions.append({
    "idx": 6,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which workshop does the theatre currently offer? (Answer 2 of 2)",
    "options": [
        {"label": "A", "text": "sound", "is_correct": False},
        {"label": "B", "text": "acting", "is_correct": False},
        {"label": "C", "text": "making puppets", "is_correct": False},
        {"label": "D", "text": "make-up", "is_correct": False},
        {"label": "E", "text": "lighting", "is_correct": True}
    ],
    "correct_answers": ["E"]
})

# Q7-10: Matching (G, D, B, F)
matching_answers = {
    7: ("box office", "G"),
    8: ("theatre manager's office", "D"),
    9: ("lighting box", "B"),
    10: ("artistic director's office", "F")
}

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
print("  - Added Q1-Q6 (Choose TWO as separate MCQ_SINGLE)")
print("  - Fixed Q7-Q10 (Matching)")
print(f"  - Total questions: {len(new_questions)}")
