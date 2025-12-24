#!/usr/bin/env python3
"""Fix script for 1507-research-project (Listening)"""
import json
from pathlib import Path

# Paths
DATA_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data")
SOURCE = "mini-ielts"
ITEM_ID = "1507-research-project"
json_path = DATA_DIR / "normalized" / SOURCE / f"{ITEM_ID}.json"

# Load data
with open(json_path) as f:
    data = json.load(f)

# === FIX 1: Replace passage with actual listening notes ===
passage_md = """# Research Project - Listening Notes

## Questions 1-6: Multiple Choice

**John's Research Project Discussion with Tutor**

1. How did John choose the topic of his research project?
   - A. He thought the information would be useful for town planning.
   - B. He has a special interest in the use of public services.
   - C. He read about a similar study which had been done earlier.

2. During his research, John is expecting to find that
   - A. The use of public services has altered very little.
   - B. A group of people has changed its habits.
   - C. The most frequently used facility is the library.

3. What is the problem with using official records?
   - A. They may be lacking in detail.
   - B. They may not be readily available.
   - C. They may be difficult to analyse.

4. What does the tutor think about John using a questionnaire to get information?
   - A. He needs to do a course in questionnaire design first.
   - B. He should use this method instead of looking at public records.
   - C. He will find the practice he gets useful the following year.

5. Which new variable does John agree to add to his investigation?
   - A. Occupation
   - B. Income group
   - C. Qualifications

6. How many questionnaires will John distribute?
   - A. The same number as in the previous study
   - B. A greater number than he needs for analysis
   - C. The number recommended in the project guidelines

---

## Questions 7-8: Choose TWO letters, A-E

Which TWO strategies will John use to encourage people to fill out his questionnaire?

- A. Using simple language
- B. Delivering the questionnaires in person
- C. Making the questionnaires anonymous
- D. Providing return envelopes
- E. Trialing the questionnaire on friends

---

## Questions 9-10: Choose TWO letters, A-E

Which TWO pieces of advice does the tutor give John about his questionnaire?

- A. There should be a mixture of question types.
- B. Some questions should elicit personal information.
- C. There should be an introduction to explain the survey's purpose.
- D. A telephone number should be provided for queries.
- E. The questions should only take a few minutes to answer."""

data['sections'][0]['passage_md'] = passage_md

# === FIX 2: Update instruction_md ===
data['sections'][0]['instruction_md'] = """**Questions 1-6:**

Choose the correct letter, **A**, **B** or **C**.

---

**Questions 7-8:**

Choose **TWO** letters, **A-E**.

Which **TWO** strategies will John use to encourage people to fill out his questionnaire?

---

**Questions 9-10:**

Choose **TWO** letters, **A-E**.

Which **TWO** pieces of advice does the tutor give John about his questionnaire?"""

# === FIX 3: Fix Q7 and add Q8, Q9, Q10 ===
# Q7-8 options (choose TWO from A-E, correct: D, E)
q7_8_options = [
    {"value": "A", "label": "A. Using simple language", "is_correct": False},
    {"value": "B", "label": "B. Delivering the questionnaires in person", "is_correct": False},
    {"value": "C", "label": "C. Making the questionnaires anonymous", "is_correct": False},
    {"value": "D", "label": "D. Providing return envelopes", "is_correct": True},
    {"value": "E", "label": "E. Trialing the questionnaire on friends", "is_correct": True}
]

# Q9-10 options (choose TWO from A-E, correct: B, C)
q9_10_options = [
    {"value": "A", "label": "A. There should be a mixture of question types.", "is_correct": False},
    {"value": "B", "label": "B. Some questions should elicit personal information.", "is_correct": True},
    {"value": "C", "label": "C. There should be an introduction to explain the survey's purpose.", "is_correct": True},
    {"value": "D", "label": "D. A telephone number should be provided for queries.", "is_correct": False},
    {"value": "E", "label": "E. The questions should only take a few minutes to answer.", "is_correct": False}
]

# Keep Q1-6, fix Q7, add Q8, Q9, Q10
new_questions = []

for q in data['questions']:
    if q['idx'] <= 6:
        new_questions.append(q)
    elif q['idx'] == 7:
        # Fix Q7 as MCQ_SINGLE (first of "choose TWO")
        q['type'] = "MULTIPLE_CHOICE_SINGLE"
        q['prompt_md'] = "Which strategy will John use to encourage people to fill out his questionnaire? (Answer 1 of 2)"
        q['options'] = q7_8_options.copy()
        q['correct_answers'] = ["D"]
        # Update is_correct for this specific question
        for opt in q['options']:
            opt['is_correct'] = (opt['value'] == "D")
        new_questions.append(q)

# Add Q8 (second of Q7-8 pair)
new_questions.append({
    "idx": 8,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which strategy will John use to encourage people to fill out his questionnaire? (Answer 2 of 2)",
    "options": [
        {"value": "A", "label": "A. Using simple language", "is_correct": False},
        {"value": "B", "label": "B. Delivering the questionnaires in person", "is_correct": False},
        {"value": "C", "label": "C. Making the questionnaires anonymous", "is_correct": False},
        {"value": "D", "label": "D. Providing return envelopes", "is_correct": False},
        {"value": "E", "label": "E. Trialing the questionnaire on friends", "is_correct": True}
    ],
    "correct_answers": ["E"]
})

# Add Q9 (first of Q9-10 pair)
new_questions.append({
    "idx": 9,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which piece of advice does the tutor give John about his questionnaire? (Answer 1 of 2)",
    "options": [
        {"value": "A", "label": "A. There should be a mixture of question types.", "is_correct": False},
        {"value": "B", "label": "B. Some questions should elicit personal information.", "is_correct": True},
        {"value": "C", "label": "C. There should be an introduction to explain the survey's purpose.", "is_correct": False},
        {"value": "D", "label": "D. A telephone number should be provided for queries.", "is_correct": False},
        {"value": "E", "label": "E. The questions should only take a few minutes to answer.", "is_correct": False}
    ],
    "correct_answers": ["B"]
})

# Add Q10 (second of Q9-10 pair)
new_questions.append({
    "idx": 10,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which piece of advice does the tutor give John about his questionnaire? (Answer 2 of 2)",
    "options": [
        {"value": "A", "label": "A. There should be a mixture of question types.", "is_correct": False},
        {"value": "B", "label": "B. Some questions should elicit personal information.", "is_correct": False},
        {"value": "C", "label": "C. There should be an introduction to explain the survey's purpose.", "is_correct": True},
        {"value": "D", "label": "D. A telephone number should be provided for queries.", "is_correct": False},
        {"value": "E", "label": "E. The questions should only take a few minutes to answer.", "is_correct": False}
    ],
    "correct_answers": ["C"]
})

data['questions'] = new_questions

# Save
with open(json_path, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ Fixed {json_path}")
print("  - Replaced passage with actual listening notes")
print("  - Updated instruction_md")
print("  - Fixed Q7 type to MCQ_SINGLE")
print("  - Added Q8, Q9, Q10")
print(f"  - Total questions: {len(new_questions)}")
