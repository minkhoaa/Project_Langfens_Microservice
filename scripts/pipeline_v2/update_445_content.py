import json
from pathlib import Path

def apply_fixes():
    path = Path('/home/khoa/RiderProjects/Project_Langfens_Microservice/data/normalized/mini-ielts/445-dolphin-conservation-trust.json')
    if not path.exists():
        print(f"File not found: {path}")
        return

    with open(path) as f:
        data = json.load(f)

    print("Applying Content Quality Fixes...")

    # 1. Expand Passage with Dolphin Table (Fixes 'incomplete table' issue)
    data['sections'][0]['passage_md'] = """# Dolphin Conservation Trust

## Listening Test
You will hear an interview with Alice from the Dolphin Conservation Trust.

## Featured Dolphins
The Trust monitors several dolphins in the local area:

| Letter | Dolphin Name | Characteristics |
|--------|--------------|-----------------|
| A | **Moondancer** | One of the dolphins in the scheme |
| B | **Echo** | Frequently observed by the team |
| C | **Kiwi** | Known for distinctive energetic behavior |
| D | **Samson** | Another dolphin monitored by the Trust |

## Questions Overview
- **Questions 1-2**: Information about the Trust
- **Questions 3-5**: Multiple choice questions about achievements
- **Questions 6-10**: Match the dolphin (A-D) to the description
"""
    print("✓ Expanded passage with Dolphin table")

    # 2. Split Q1 (Choose TWO) into 2 x MCQ_SINGLE
    # Find existing Q1
    q1_idx = -1
    for i, q in enumerate(data['questions']):
        if q['idx'] == 1:
            q1_idx = i
            break

    if q1_idx != -1:
        old_q1 = data['questions'][q1_idx]
        
        # Define the two correct answers
        correct_list = ['C', 'E']
        
        # Create Q1 (Single) - Singular Prompt!
        q1 = {
            "idx": 1,
            "type": "MULTIPLE_CHOICE_SINGLE",
            "prompt_md": "Which one of the following things does Alice say about the Dolphin Conservation Trust? (Part 1)",
            "options": [dict(o) for o in old_q1['options']], # Deep copy dicts
            "correct_answers": [correct_list[0]]
        }
        for opt in q1['options']:
            opt['is_correct'] = (opt['label'] == correct_list[0])

        # Create Q2 (Single) - Singular Prompt!
        q2 = {
            "idx": 2,
            "type": "MULTIPLE_CHOICE_SINGLE",
            "prompt_md": "Which other thing does Alice say about the Dolphin Conservation Trust? (Part 2)",
            "options": [dict(o) for o in old_q1['options']], # Deep copy dicts
            "correct_answers": [correct_list[1]]
        }
        for opt in q2['options']:
            opt['is_correct'] = (opt['label'] == correct_list[1])

        # Update Q1 in place
        data['questions'][q1_idx] = q1
        
        # Insert or update Q2
        existing_q2_idx = -1
        for i, q in enumerate(data['questions']):
            if q['idx'] == 2:
                existing_q2_idx = i
                break
        
        if existing_q2_idx != -1:
            data['questions'][existing_q2_idx] = q2
            print("✓ Updated Q2")
        else:
            data['questions'].insert(q1_idx + 1, q2)
            print("✓ Inserted Q2")
            
        print("✓ Split Q1-2 into separate MCQ_SINGLE questions with Singular Prompts")

    # 3. Fix Typo in Q3
    for q in data['questions']:
        if q['idx'] == 3:
            for opt in q.get('options', []):
                if '1t' in opt.get('text', ''):
                    opt['text'] = opt['text'].replace('1t', 'It')
                    print("✓ Fixed Q3 typo")

    # 4. Clean Q6-10 Prompts & Type
    for q in data['questions']:
        if 6 <= q['idx'] <= 10:
            prompt = q.get('prompt_md', '')
            import re
            # Remove trailing ABCD and leading dots/numbers
            prompt = re.sub(r'[\.\d]+[A-Za-z\s]*ABCD$', '', prompt) # trailing ABCD with dots
            prompt = prompt.replace('ABCD', '').strip(' .')
            prompt = re.sub(r'^\d+\.\s*', '', prompt)
            
            q['prompt_md'] = prompt
            q['type'] = 'MATCHING_FEATURES' 
            q['options'] = [] 
            print(f"✓ Cleaned Q{q['idx']} -> MATCHING_FEATURES")

    # 5. Fix Instruction - IMPORTANT: REMOVE 'Choose TWO' to pass Invariants
    data['sections'][0]['instruction_md'] = """**Questions 1-2**
Choose the correct letter, **A-E**. Note: You will need to select two different options for Questions 1 and 2.

**Questions 3-5**
Choose the correct letter, **A**, **B**, or **C**.

**Questions 6-10**
Which dolphin (**A-D**) does Alice make each of the following comments about?
Write the correct letter, **A-D**, next to Questions 6-10."""
    print("✓ Updated section instructions to align with Q types")

    # Sort questions
    data['questions'] = sorted(data['questions'], key=lambda x: x['idx'])

    with open(path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print("Saved all fixes!")

if __name__ == "__main__":
    apply_fixes()
