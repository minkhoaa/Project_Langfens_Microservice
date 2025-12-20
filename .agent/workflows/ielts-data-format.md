---
description: Quy tắc format dữ liệu IELTS questions - KHÔNG SỬA BACKEND/FRONTEND
---

# /ielts-data-format - IELTS Data Formatting Rules

**MỤC ĐÍCH**: Đảm bảo dữ liệu IELTS render đúng trên frontend.
**LƯU Ý**: Chỉ fix DATA, KHÔNG sửa code backend/frontend.

---

## 📝 TEXT FORMATTING RULES

### 1. CAPITALIZATION
```
❌ SAI: "what page would you turn to..."
✅ ĐÚNG: "What page would you turn to..."

❌ SAI: "TRUE", "false", "Not Given"  
✅ ĐÚNG: "TRUE", "FALSE", "NOT GIVEN" (all caps cho TFNG)

❌ SAI: "a", "b", "c" (lowercase options)
✅ ĐÚNG: "A", "B", "C" (uppercase options)
```

### 2. WORD SPACING (chữ dính liền)
```
❌ SAI: "stone-polishing industry.Comfortable footwear"
✅ ĐÚNG: "stone-polishing industry. Comfortable footwear"

❌ SAI: "£2 per person.B Enjoy a film"
✅ ĐÚNG: "£2 per person.\n\n**B.** Enjoy a film"

❌ SAI: "Answer:1. A2. B"
✅ ĐÚNG: "Answer: 1. A  2. B"
```

### 3. LINE BREAKS (xuống dòng)
```
❌ SAI: "**A.** Para A **B.** Para B **C.** Para C"
✅ ĐÚNG:
"**A.** Para A

**B.** Para B

**C.** Para C"

❌ SAI: Passage và questions liền nhau
✅ ĐÚNG: Passage và questions cách nhau bằng "---" hoặc blank lines
```

### 4. PUNCTUATION
```
❌ SAI: "What is your name _______?"  (? sau blank)
✅ ĐÚNG: "What is your name? _______" (? trước blank)

❌ SAI: "Complete the sentence:_______"
✅ ĐÚNG: "Complete the sentence: _______" (space trước blank)

❌ SAI: "para A.para B"
✅ ĐÚNG: "para A. Para B" hoặc line break
```

---

## 📄 PASSAGE FORMATTING

### Paragraph Labels (A, B, C...)
```markdown
✅ CORRECT FORMAT:
**A.** Content of paragraph A here. Multiple sentences
can span across lines.

**B.** Content of paragraph B here.

**C.** Content of paragraph C here.
```

### Section Dividers
```markdown
✅ For multiple passages:
**Passage 1: Title Here**

Content...

---

**Passage 2: Second Title**

Content...
```

### Lists in Passages
```markdown
✅ For bullet lists:
- item one
- item two
- item three

✅ For prevention/symptoms lists:
**A. Prevention**
- leave snakes alone
- do not put hands in hollow logs
- be noisy when walking
```

---

## ❓ QUESTION FORMATTING

### Prompt Text
```
✅ Full sentence, properly capitalized
✅ Ends with blank marker for COMPLETION types
✅ No trailing spaces
✅ No HTML tags or entities

❌ "Question 1" (placeholder)
❌ "question text?" (missing capital)
❌ "Text_______" (no space before blank)
```

### Blank Markers
```
✅ Standard: _______  (7 underscores)
✅ With punctuation: "word? _______" or "word _______."
✅ Multiple blanks: "_______ and _______"

❌ "___" (too short)
❌ "………" (ellipsis - convert to _______)
❌ "____?" (? after blank)
```

### Option Labels
```
✅ MATCHING: "A", "B", "C", "D" (single letter)
✅ HEADING: "i", "ii", "iii" + " - heading text"
✅ MCQ: "A. Full option text here"
✅ TFNG: "TRUE", "FALSE", "NOT GIVEN"

❌ Full paragraphs as option labels
❌ Lowercase letters for MATCHING
❌ Mixed case for TFNG
```

---

## 🚫 NOISE PATTERNS TO REMOVE

### From Passages
```
❌ "Questions 1-8" (question numbers in passage)
❌ "Write the correct letter" (instructions in passage)
❌ "Answer: 1. A 2. B" (answers in passage)
❌ Cookie/privacy notices
❌ "Show/Hide Answers" buttons
❌ Navigation links ("Prev | Next")
❌ Social share buttons
❌ Advertisement text
```

### From Questions
```
❌ "Choose ONE WORD ONLY" (instruction, not prompt)
❌ "NB You may use..." (instruction)
❌ "Write your answers in boxes..." (instruction)
❌ Line numbers like "1.", "2." at start (handled by idx)
```

---

## 🔄 COMMON TRANSFORMATIONS

### Ellipsis to Blank
```python
text = text.replace('………', '_______')
text = text.replace('...', '_______')
text = text.replace('…', '_______')
```

### Fix Merged Words
```python
# Add space after period if missing
text = re.sub(r'\.([A-Z])', r'. \1', text)

# Add newline before paragraph labels
text = re.sub(r'([.!?])\s*([A-H]\.)', r'\1\n\n**\2**', text)
```

### Normalize Whitespace
```python
# Multiple spaces to single
text = re.sub(r' +', ' ', text)

# Multiple newlines to double
text = re.sub(r'\n{3,}', '\n\n', text)

# Trim lines
text = '\n'.join(line.strip() for line in text.split('\n'))
```

### Fix Capitalization
```python
# Capitalize first letter of sentences
text = re.sub(r'([.?!]\s+)([a-z])', lambda m: m.group(1) + m.group(2).upper(), text)

# Capitalize first letter of prompt
if text and text[0].islower():
    text = text[0].upper() + text[1:]
```

---

## ✅ VALIDATION CHECKLIST

Before finalizing data, check:

### Passages
- [ ] Every paragraph has **A.** **B.** labels (bold + period)
- [ ] Line breaks between paragraphs
- [ ] No questions/instructions embedded
- [ ] No answer key embedded
- [ ] No noise (ads, nav, cookies)
- [ ] Proper sentence spacing

### Questions
- [ ] Prompts start with capital letter
- [ ] Blank markers are `_______` (7 underscores)
- [ ] Blanks have space before them
- [ ] Question marks before blank (not after)
- [ ] No placeholder text ("Question 1")

### Options
- [ ] MATCHING: Single uppercase letters
- [ ] TFNG/YNNG: All caps
- [ ] MCQ: "A. text" format
- [ ] No duplicate options
- [ ] Correct answer exists in options

### Answers
- [ ] Every question has correct_answers
- [ ] Format matches source exactly
- [ ] Multiple answers: "A, E" (with comma space)

---

## 📋 PYTHON CLEANUP TEMPLATE

```python
import re
import json
from pathlib import Path

def clean_text(text: str) -> str:
    """Apply all text formatting rules."""
    # Fix merged words
    text = re.sub(r'\.([A-Z])', r'. \1', text)
    
    # Normalize whitespace
    text = re.sub(r' +', ' ', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    # Capitalize first letter
    if text and text[0].islower():
        text = text[0].upper() + text[1:]
    
    # Convert ellipsis to blank
    text = text.replace('………', '_______')
    text = text.replace('...', '_______')
    
    return text.strip()

def clean_prompt(prompt: str, q_type: str) -> str:
    """Clean question prompt."""
    prompt = clean_text(prompt)
    
    # Add blank for completion types
    COMPLETION_TYPES = {'SHORT_ANSWER', 'SUMMARY_COMPLETION', 'SENTENCE_COMPLETION'}
    if q_type in COMPLETION_TYPES:
        if '_______' not in prompt:
            if prompt.endswith('?'):
                prompt = prompt + ' _______'
            else:
                prompt = prompt.rstrip('.') + ' _______.'
    
    return prompt

def format_passage(passage: str) -> str:
    """Format passage with paragraph labels."""
    # Add bold labels
    passage = re.sub(r'\n([A-H])\.\s+', r'\n\n**\1.** ', passage)
    passage = re.sub(r'^([A-H])\.\s+', r'**\1.** ', passage)
    
    return passage.strip()
```
