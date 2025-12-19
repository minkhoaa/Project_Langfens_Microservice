#!/usr/bin/env python3
"""
IELTS Exam Data Crawler - ielts-writing.info
=============================================
Crawls IELTS reading exams from ielts-writing.info and exports to SQL.

Usage:
    python crawler-ieltswriting.py [URL]
    
Example:
    python crawler-ieltswriting.py https://www.ielts-writing.info/EXAM/ielts_reading/1224/

STANDARDIZED QUESTION FORMATS (v3.0) - LOCKED
==============================================
⚠️ DO NOT MODIFY BACKEND OR FRONTEND - ONLY DATA/SCRIPT CHANGES ALLOWED

1. YES_NO_NOT_GIVEN / TRUE_FALSE_NOT_GIVEN:
   - Type: YES_NO_NOT_GIVEN or TRUE_FALSE_NOT_GIVEN
   - options: 3 fixed choices with IsCorrect flag
   - correct_answer: string (YES/NO/NOT GIVEN or TRUE/FALSE/NOT GIVEN)
   - MatchPairs: NULL
   - HTML: <p class="inline-question"> + <span data-answer='YES'>

2. MULTIPLE_CHOICE_SINGLE:
   - Type: MULTIPLE_CHOICE_SINGLE
   - options: A-D with "A. " prefix in ContentMd labels, one IsCorrect=true
   - correct_answer: letter
   - MatchPairs: NULL
   - HTML: <div class="mchq" data-answer="D">

3. MATCHING_HEADING: ⭐ Requires MatchPairs with FULL LABEL
   - Type: MATCHING_HEADING
   - options: roman numerals (i-ix) with full label (e.g., "i. The beginning...")
   - correct_answer: roman numeral (lowercase)
   - MatchPairs: {"section-a-q1": ["i. Full heading text here"]}
     ⚠️ CRITICAL: MatchPairs MUST contain FULL LABEL, not just "i"
   - HTML: <p class="inline-question"> + <div class="lows-headers">

4. MATCHING_FEATURES: ⭐ Requires MatchPairs with FULL LABEL  
   - Type: MATCHING_FEATURES
   - options: A/B/C from data-items attribute
   - correct_answer: letter
   - MatchPairs: {"feature-q6": ["C. Full option text"]}
     ⚠️ CRITICAL: MatchPairs MUST contain FULL LABEL, not just "C"
   - HTML: <span data-items='A / B / C' data-answer='C'>

5. MATCHING_INFORMATION (Paragraph Matching):
   - Type: MATCHING_INFORMATION
   - options: empty (user types letter A-J)
   - correct_answer: letter A-J
   - MatchPairs: {"paragraph": ["I"]} - contains paragraph letter
   - HTML: <p class="sq"> + <div class="lows-2">

6. SUMMARY_COMPLETION (Fill-in-blank):
   - Type: SUMMARY_COMPLETION
   - options: empty
   - correct_answer: word/phrase
   - BlankAcceptTexts: {"blank1": ["accepted", "answers"]}
   - HTML: gaps in text

INDEXING RULES:
===============
- Idx starts at 1 and MUST be unique per exam (no duplicates)
- MC questions start after dropdown questions (use max_dropdown_idx + 1)
"""

import requests
from bs4 import BeautifulSoup
import json
import re
import uuid
import logging
from pathlib import Path
from datetime import datetime
from typing import Any

# Configuration
TARGET_URL = "https://www.ielts-writing.info/EXAM/ielts_reading/1224/"
OUTPUT_DIR = Path(__file__).parent
SEEDS_DIR = Path(__file__).parent.parent.parent / "deploy" / "seeds"

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Headers to avoid being blocked
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
}

# Known answers for specific exams (since answers require JS click to reveal)
# Format: {exam_id: {question_num: answer}}
KNOWN_ANSWERS = {
    "1224": {
        1: "YES",
        2: "YES", 
        3: "NO",
        4: "NOT GIVEN",
        5: "NO",
        6: "D",  # Action to protect fish stocks is urgently needed
        7: "C",  # Based on predictions which were inaccurate
        8: "A",  # The means of avoiding worst outcomes needs to be prioritised
        9: "B",  # controls
        10: "F", # fishing techniques
        11: "D", # fish catches
        12: "I", # the land
        13: "H", # marine reserves
        14: "C", # failure
    }
}


def fetch_page(url: str) -> BeautifulSoup:
    """Fetch and parse a page."""
    response = requests.get(url, headers=HEADERS, timeout=30)
    response.raise_for_status()
    return BeautifulSoup(response.text, 'html.parser')


def extract_passage(soup: BeautifulSoup, base_url: str) -> dict:
    """Extract passage content from the reading paper link."""
    # Find reading paper link
    reading_link = soup.find('a', class_='reading-link')
    if not reading_link:
        # Try finding by text
        reading_link = soup.find('a', string=re.compile(r'Reading paper', re.I))
    
    passage_text = ""
    passage_title = ""
    
    if reading_link:
        passage_url = reading_link.get('href', '')
        if not passage_url.startswith('http'):
            # Relative URL - construct full URL
            from urllib.parse import urljoin
            passage_url = urljoin(base_url, passage_url)
        
        try:
            logger.info(f"Fetching passage from: {passage_url}")
            passage_soup = fetch_page(passage_url)
            
            # Extract title
            title_elem = passage_soup.find('h1') or passage_soup.find('h2')
            if title_elem:
                passage_title = title_elem.get_text(strip=True)
            
            # Extract passage text - usually in body or main content
            body = passage_soup.find('body')
            if body:
                # Remove scripts and styles
                for tag in body.find_all(['script', 'style', 'nav', 'header', 'footer']):
                    tag.decompose()
                passage_text = body.get_text(separator='\n', strip=True)
        except Exception as e:
            logger.warning(f"Failed to fetch passage: {e}")
    
    return {
        'title': passage_title,
        'text': passage_text
    }


def extract_exam_title(soup: BeautifulSoup) -> str:
    """Extract exam title from page."""
    # Try h1 first
    h1 = soup.find('h1')
    if h1:
        return h1.get_text(strip=True)
    
    # Try title tag
    title = soup.find('title')
    if title:
        text = title.get_text(strip=True)
        # Clean up title
        text = re.sub(r'\s*\|\s*IELTS.*$', '', text)
        return text
    
    return "IELTS Reading Test"


def extract_word_list(soup: BeautifulSoup) -> dict:
    """Extract word list/word bank from .lows-2 container.
    
    Returns dict like {'A': 'action', 'B': 'controls', ...}
    """
    word_list = {}
    
    # Find the word list container (div with class lows-2)
    word_container = soup.find('div', class_='lows-2')
    
    if word_container:
        # Each child div contains: <span class="lows-l">A</span> word
        for item in word_container.find_all('div', recursive=False):
            letter_span = item.find('span', class_='lows-l')
            if letter_span:
                letter = letter_span.get_text(strip=True).upper()
                # Get the word (text after the span)
                word = item.get_text(strip=True)
                # Remove the letter from the word
                word = word.replace(letter, '', 1).strip()
                word_list[letter] = word
    
    # If no word list found, return empty dict
    return word_list


def extract_heading_list(soup: BeautifulSoup) -> list[dict]:
    """Extract heading list from .lows-headers container.
    
    Returns list like [{'value': 'i', 'label': 'i. Shielding the earth...'}, ...]
    """
    headings = []
    
    # Find heading list container (div with class lows-headers)
    heading_container = soup.find('div', class_='lows-headers')
    
    if heading_container:
        # Each child div contains: <span>i</span><span>Heading title</span>
        for item in heading_container.find_all('div', recursive=False):
            spans = item.find_all('span')
            if len(spans) >= 2:
                numeral = spans[0].get_text(strip=True).lower()
                title = spans[1].get_text(strip=True)
                if numeral and title:
                    headings.append({
                        'value': numeral,
                        'label': f"{numeral}. {title}",
                        'is_correct': False  # Will be set per question
                    })
            elif len(spans) == 1:
                # Single span with numeral only
                numeral = spans[0].get_text(strip=True).lower()
                if re.match(r'^[ivxlcdm]+$', numeral):  # Roman numeral
                    # Get text after span
                    text = item.get_text(strip=True)
                    text = text.replace(numeral, '', 1).strip()
                    if text:
                        headings.append({
                            'value': numeral,
                            'label': f"{numeral}. {text}",
                            'is_correct': False
                        })
    
    return headings


def extract_questions(soup: BeautifulSoup) -> list[dict]:
    """Extract all questions from the page using ielts-writing.info HTML structure."""
    questions = []
    
    # Pattern 1: Extract YES/NO/NOT GIVEN and Summary Completion from .data-answer spans
    dropdown_questions = extract_dropdown_questions(soup)
    questions.extend(dropdown_questions)
    
    # Calculate starting index for MC questions based on dropdown questions
    max_dropdown_idx = max((q['idx'] for q in dropdown_questions), default=0)
    
    # Pattern 2: Multiple choice questions from .mchq divs
    mc_questions = extract_mchq_questions(soup, start_idx=max_dropdown_idx + 1)
    questions.extend(mc_questions)
    
    # Sort by question index
    questions.sort(key=lambda q: q['idx'])
    
    return questions


def extract_dropdown_questions(soup: BeautifulSoup) -> list[dict]:
    """Extract YES/NO/NOT GIVEN and Summary Completion questions."""
    questions = []
    
    # Pattern 1: YES/NO/NOT GIVEN from p.inline-question
    inline_questions = soup.find_all('p', class_='inline-question')
    for p in inline_questions:
        # Find span with data-answer attribute
        answer_span = p.find('span', attrs={'data-answer': True})
        if not answer_span:
            continue
        
        correct_answer = answer_span.get('data-answer', '').strip().upper()
        
        # Get question text from paragraph
        prompt = p.get_text(separator=' ', strip=True)
        prompt = re.sub(r'\s+', ' ', prompt)
        
        # Extract question number from <strong> tag or text
        q_num = 0
        strong = p.find('strong')
        if strong:
            num_text = strong.get_text(strip=True)
            if num_text.isdigit():
                q_num = int(num_text)
        
        if q_num == 0:
            # Try to find from text
            num_match = re.match(r'^(\d+)', prompt)
            if num_match:
                q_num = int(num_match.group(1))
        
        # Clean prompt - remove number at start
        prompt = re.sub(r'^\d+\s*', '', prompt)
        
        # Skip example questions (data-readonly=true)
        if answer_span.get('data-readonly') == 'true':
            continue
        
        # Check for data-items attribute (MATCHING_FEATURES with options)
        data_items = answer_span.get('data-items', '')
        
        # Determine type based on correct answer format and data-items
        if correct_answer in ['YES', 'NO', 'NOT GIVEN']:
            q_type = 'YES_NO_NOT_GIVEN'
            options = [
                {'label': 'YES', 'value': 'YES', 'is_correct': correct_answer == 'YES'},
                {'label': 'NO', 'value': 'NO', 'is_correct': correct_answer == 'NO'},
                {'label': 'NOT GIVEN', 'value': 'NOT GIVEN', 'is_correct': correct_answer == 'NOT GIVEN'},
            ]
        elif correct_answer in ['TRUE', 'FALSE']:
            q_type = 'TRUE_FALSE_NOT_GIVEN'
            options = [
                {'label': 'TRUE', 'value': 'TRUE', 'is_correct': correct_answer == 'TRUE'},
                {'label': 'FALSE', 'value': 'FALSE', 'is_correct': correct_answer == 'FALSE'},
                {'label': 'NOT GIVEN', 'value': 'NOT GIVEN', 'is_correct': correct_answer == 'NOT GIVEN'},
            ]
        elif data_items:
            # MATCHING_FEATURES with options like "A / B / C"
            q_type = 'MATCHING_FEATURES'
            item_list = [i.strip() for i in data_items.split('/')]
            options = [
                {'label': item, 'value': item, 'is_correct': item == correct_answer}
                for item in item_list
            ]
        elif re.match(r'^[ivxIVX]+$', correct_answer.lower()):
            # MATCHING_HEADING with roman numerals (i, ii, iii, iv, etc.)
            q_type = 'MATCHING_HEADING'
            # Get heading list from page
            heading_list = extract_heading_list(soup)
            correct_lower = correct_answer.lower()
            options = [
                {'label': h['label'], 'value': h['value'], 'is_correct': h['value'] == correct_lower}
                for h in heading_list
            ]
        elif len(correct_answer) == 1 and correct_answer.isalpha():
            # Single letter answer (A-Z) - MATCHING_INFORMATION
            q_type = 'MATCHING_INFORMATION'
            options = []
        else:
            continue  # Skip unknown types
        
        if q_num > 0:
            # Capitalize first letter of prompt
            clean_prompt = prompt[:500] if prompt else f"Question {q_num}"
            if clean_prompt and len(clean_prompt) > 0:
                clean_prompt = clean_prompt[0].upper() + clean_prompt[1:]
            
            questions.append({
                'idx': q_num,
                'type': q_type,
                'prompt': clean_prompt,
                'options': options,
                'correct_answer': correct_answer
            })
    
    # Pattern 2: Summary Completion from p.sq with span[data-answer]
    # First, extract word list from .lows-2 container
    word_list = extract_word_list(soup)
    word_list_text = "\n".join([f"{letter}. {word}" for letter, word in word_list.items()])
    
    sq_paragraphs = soup.find_all('p', class_='sq')
    sq_question_idx = 8  # Summary questions start at Q9 (after 5 YNNG + 3 MC)
    
    # First pass: collect all blanks and their question numbers
    all_blanks = []
    for p in sq_paragraphs:
        answer_spans = p.find_all('span', attrs={'data-answer': True})
        for span in answer_spans:
            correct_answer = span.get('data-answer', '').strip().upper()
            if len(correct_answer) == 1 and correct_answer.isalpha():
                sq_question_idx += 1
                all_blanks.append({
                    'paragraph': p,
                    'span': span,
                    'q_num': sq_question_idx,
                    'correct_answer': correct_answer
                })
    
    # Second pass: create questions with numbered blanks
    for blank_info in all_blanks:
        p = blank_info['paragraph']
        current_q_num = blank_info['q_num']
        correct_answer = blank_info['correct_answer']
        
        # Create a copy of the paragraph HTML
        prompt_html = str(p)
        
        # Find all blanks in this paragraph and number them
        blank_counter = [b for b in all_blanks if b['paragraph'] == p]
        for b in blank_counter:
            # Replace each span with numbered blank
            span_pattern = re.escape(str(b['span']))
            numbered_blank = f" ___[{b['q_num']}] "
            prompt_html = prompt_html.replace(str(b['span']), numbered_blank, 1)
        
        prompt_soup = BeautifulSoup(prompt_html, 'html.parser')
        prompt = prompt_soup.get_text(separator=' ', strip=True)
        prompt = re.sub(r'\s+', ' ', prompt)[:400]
        
        # Build full prompt with word list
        full_prompt = f"**Q{current_q_num}** - Fill in blank ___[{current_q_num}]:\n\n{prompt}\n\n**Word List:**\n{word_list_text}"
        
        questions.append({
            'idx': current_q_num,
            'type': 'MATCHING_INFORMATION',
            'prompt': full_prompt,
            'options': [],
            'correct_answer': correct_answer
        })
    
    return questions


def extract_mchq_questions(soup: BeautifulSoup, start_idx: int = 7) -> list[dict]:
    """Extract multiple choice questions from .mchq containers."""
    questions = []
    
    # Find all .mchq divs (Multiple Choice Question containers)
    mchq_divs = soup.find_all('div', class_='mchq', attrs={'data-answer': True})
    
    for idx, div in enumerate(mchq_divs):
        correct_answer = div.get('data-answer', '').strip().upper()
        
        # MC questions start after dropdown questions (dynamic start_idx)
        q_num = start_idx + idx
        
        # Find question stem - look for preceding paragraph or h4
        prompt = ""
        prev = div.find_previous_sibling(['p', 'h4'])
        if prev:
            text = prev.get_text(strip=True)
            # Extract just the question part (after the number)
            match = re.match(r'^\d+\s*(.+)', text)
            if match:
                prompt = match.group(1)
            else:
                prompt = text
        
        # If prompt is still empty or too short, use a generic one
        if len(prompt) < 10:
            prompt = f"Choose the correct answer for question {q_num}."
        
        # Extract options from .custom-control-label elements
        options = []
        option_labels = div.find_all('label', class_='custom-control-label')
        
        for label in option_labels:
            # Get the full option text
            opt_text = label.get_text(strip=True)
            
            # Extract option letter (A, B, C, D, etc.)
            radio_input = label.find_previous_sibling('input', {'type': 'radio'})
            opt_value = radio_input.get('value', '').upper() if radio_input else ''
            
            # Clean up option text - add space after letter if missing
            # Pattern: "AThe means..." -> "A. The means..."
            cleaned_text = re.sub(r'^([A-F])([A-Z])', r'\1. \2', opt_text)
            
            if not opt_value:
                # Try to extract from label text
                letter_match = re.match(r'^([A-F])[\.\s]', cleaned_text)
                if letter_match:
                    opt_value = letter_match.group(1)
            
            is_correct = opt_value == correct_answer
            
            options.append({
                'label': cleaned_text,
                'value': opt_value,
                'is_correct': is_correct
            })
        
        questions.append({
            'idx': q_num,
            'type': 'MULTIPLE_CHOICE_SINGLE',
            'prompt': prompt[:500] if prompt else f"Question {q_num}",
            'options': options,
            'correct_answer': correct_answer
        })
    
    return questions


def extract_blank_questions(soup: BeautifulSoup, start_idx: int) -> list[dict]:
    """Extract fill-in-the-blank questions (legacy, not used for ielts-writing.info)."""
    # This function is kept for compatibility but ielts-writing.info uses dropdowns
    return []


def generate_sql(data: dict) -> str:
    """Generate SQL insert statements."""
    title = data.get('title', 'IELTS Reading Test')
    slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
    slug = f"ielts-reading-{slug}"
    
    passage = data.get('passage', {})
    questions = data.get('questions', [])
    
    sql_lines = [
        "-- ============================================",
        f"-- IELTS Exam Data Import SQL",
        f"-- Generated: {datetime.now().isoformat()}",
        f"-- Source: ielts-writing.info",
        f"-- Title: {title}",
        "-- ============================================",
        "",
        "BEGIN;",
        "CREATE EXTENSION IF NOT EXISTS pgcrypto;",
        "",
        f"-- Cleanup existing data for slug: {slug}",
        f"DELETE FROM exam_options WHERE \"QuestionId\" IN (",
        f"  SELECT q.\"Id\" FROM exam_questions q",
        f"  JOIN exam_sections s ON s.\"Id\" = q.\"SectionId\"",
        f"  JOIN exams e ON e.\"Id\" = s.\"ExamId\"",
        f"  WHERE e.\"Slug\" = '{slug}'",
        ");",
        f"DELETE FROM exam_questions USING exam_sections s, exams e",
        f"WHERE exam_questions.\"SectionId\" = s.\"Id\"",
        f"  AND s.\"ExamId\" = e.\"Id\"",
        f"  AND e.\"Slug\" = '{slug}';",
        f"DELETE FROM exam_sections USING exams e",
        f"WHERE exam_sections.\"ExamId\" = e.\"Id\"",
        f"  AND e.\"Slug\" = '{slug}';",
        f"DELETE FROM exams",
        f"WHERE \"Slug\" = '{slug}';",
        "",
        "DO $$",
        "DECLARE",
        "  exam_id uuid := gen_random_uuid();",
        "  sec1 uuid := gen_random_uuid();",
        "  qid uuid;",
        "BEGIN",
        "",
    ]
    
    # Insert exam
    sql_lines.extend([
        f"  INSERT INTO exams (\"Id\",\"Slug\",\"Title\",\"DescriptionMd\",\"Category\",\"Level\",\"Status\",\"DurationMin\",\"UpdatedAt\")",
        "  VALUES (",
        f"    exam_id,",
        f"    '{slug}',",
        f"    '{escape_sql(title)}',",
        f"    'IELTS Reading Practice Test: {escape_sql(title)}',",
        f"    'IELTS',",
        f"    'B2',",
        f"    'PUBLISHED',",
        f"    20,",
        f"    now()",
        "  );",
        "",
    ])
    
    # Insert section with passage
    passage_text = escape_sql(passage.get('text', '')[:8000])  # Limit length
    sql_lines.extend([
        f"  INSERT INTO exam_sections (\"Id\",\"ExamId\",\"Idx\",\"Title\",\"InstructionsMd\")",
        "  VALUES (",
        f"    sec1,",
        f"    exam_id,",
        f"    1,",
        f"    'Reading Passage - {escape_sql(title)}',",
        f"    E'# Passage\\n\\n{passage_text}'",
        "  );",
        "",
    ])
    
    # Insert questions
    for q in questions:
        q_type = q.get('type', 'SUMMARY_COMPLETION')
        q_prompt = escape_sql(q.get('prompt', ''))
        q_idx = q.get('idx', 1)
        options = q.get('options', [])
        correct = q.get('correct_answer')
        
        if q_type in ['TRUE_FALSE_NOT_GIVEN', 'YES_NO_NOT_GIVEN', 'MULTIPLE_CHOICE_SINGLE', 'MATCHING_HEADING', 'MATCHING_FEATURES']:
            # Build MatchPairs for MATCHING_HEADING type
            match_pairs_sql = 'NULL'
            if q_type == 'MATCHING_HEADING' and correct:
                # Find the full label for correct answer (e.g., "vii. Why attempt geoengineering?")
                correct_label = correct.lower()
                for opt in options:
                    if opt.get('value', '').lower() == correct.lower() or opt.get('is_correct'):
                        correct_label = escape_sql(opt.get('label', correct.lower()))
                        break
                # Format: {"section-q1": ["vii. Full heading text"]} 
                prompt_key = q_prompt.lower().replace(' ', '-') + f"-q{q_idx}"
                match_pairs_sql = f"'{{\"{prompt_key}\": [\"{correct_label}\"]}}'"
            elif q_type == 'MATCHING_FEATURES' and correct:
                # Find the full label for correct answer (e.g., "C. carbon capture")
                correct_label = correct
                for opt in options:
                    if opt.get('value') == correct or opt.get('is_correct'):
                        correct_label = escape_sql(opt.get('label', correct))
                        break
                # Format: {"feature-q6": ["C"]}
                prompt_key = f"feature-q{q_idx}"
                match_pairs_sql = f"'{{\"{prompt_key}\": [\"{correct_label}\"]}}'"
            
            sql_lines.extend([
                f"  qid := gen_random_uuid();",
                f"  INSERT INTO exam_questions (\"Id\",\"SectionId\",\"Idx\",\"Type\",\"Skill\",\"Difficulty\",\"PromptMd\",\"ExplanationMd\",\"MatchPairs\")",
                f"  VALUES (",
                f"    qid,",
                f"    sec1,",
                f"    {q_idx},",
                f"    '{q_type}',",
                f"    'READING',",
                f"    2,",
                f"    '{q_prompt}',",
                f"    'Choose the correct answer.',",
                f"    {match_pairs_sql}",
                f"  );",
            ])
            
            for i, opt in enumerate(options):
                is_correct = 'true' if opt.get('is_correct') or opt.get('value') == correct else 'false'
                opt_label = escape_sql(opt.get('label', opt.get('value', '')))
                sql_lines.append(
                    f"  INSERT INTO exam_options (\"Id\",\"QuestionId\",\"Idx\",\"ContentMd\",\"IsCorrect\") VALUES "
                    f"(gen_random_uuid(), qid, {i+1}, '{opt_label}', {is_correct});"
                )
            sql_lines.append("")
            
        else:  # SUMMARY_COMPLETION
            blank_key = f"blank-q{q_idx}"
            answers = [correct] if correct else []
            sql_lines.extend([
                f"  qid := gen_random_uuid();",
                f"  INSERT INTO exam_questions (\"Id\",\"SectionId\",\"Idx\",\"Type\",\"Skill\",\"Difficulty\",\"PromptMd\",\"ExplanationMd\",\"BlankAcceptTexts\")",
                f"  VALUES (",
                f"    qid,",
                f"    sec1,",
                f"    {q_idx},",
                f"    '{q_type}',",
                f"    'READING',",
                f"    2,",
                f"    '{q_prompt}',",
                f"    'Complete the blank with words from the passage.',",
                f"    '{{\"{blank_key}\": {json.dumps(answers)}}}'::jsonb",
                f"  );",
                "",
            ])
    
    sql_lines.extend([
        "",
        "END$$;",
        "",
        "",
        "COMMIT;",
    ])
    
    return '\n'.join(sql_lines)


def escape_sql(text: str) -> str:
    """Escape text for SQL."""
    if not text:
        return ""
    return text.replace("'", "''").replace("\\", "\\\\").replace("\n", "\\n")


def main():
    import sys
    
    url = sys.argv[1] if len(sys.argv) > 1 else TARGET_URL
    
    logger.info("=" * 60)
    logger.info("IELTS Exam Crawler (ielts-writing.info) - Starting")
    logger.info("=" * 60)
    logger.info(f"Target URL: {url}")
    
    # Step 1: Fetch main page
    logger.info("Phase 1: Fetching main page...")
    soup = fetch_page(url)
    
    # Step 2: Extract exam title
    title = extract_exam_title(soup)
    logger.info(f"Exam title: {title}")
    
    # Step 3: Extract passage
    logger.info("Phase 2: Extracting passage...")
    passage = extract_passage(soup, url)
    logger.info(f"Passage title: {passage.get('title', 'N/A')}")
    logger.info(f"Passage length: {len(passage.get('text', ''))} chars")
    
    # Step 4: Extract questions
    logger.info("Phase 3: Extracting questions...")
    questions = extract_questions(soup)
    logger.info(f"Extracted {len(questions)} questions")
    
    for q in questions:
        logger.info(f"  Q{q['idx']}: {q['type']} - {q.get('correct_answer', 'No answer')}")
    
    # Step 5: Build data structure
    data = {
        'title': title,
        'source_url': url,
        'passage': passage,
        'questions': questions
    }
    
    # Step 6: Save raw data
    raw_file = OUTPUT_DIR / "raw_data_ieltswriting.json"
    with open(raw_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    logger.info(f"Raw data saved to: {raw_file}")
    
    # Step 7: Generate SQL
    logger.info("Phase 4: Generating SQL...")
    sql = generate_sql(data)
    
    # Step 8: Save SQL
    slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
    sql_file = SEEDS_DIR / f"seed_exam_{slug[:50]}.sql"
    SEEDS_DIR.mkdir(parents=True, exist_ok=True)
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write(sql)
    logger.info(f"SQL saved to: {sql_file}")
    
    logger.info("=" * 60)
    logger.info("IELTS Exam Crawler - Complete")
    logger.info("=" * 60)


if __name__ == "__main__":
    main()
