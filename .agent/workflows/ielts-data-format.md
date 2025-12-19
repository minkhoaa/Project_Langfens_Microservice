---
description: Quy tắc format dữ liệu IELTS questions - KHÔNG SỬA BACKEND/FRONTEND
---

# IELTS Question Data Format Rules (LOCKED)

⚠️ **QUAN TRỌNG**: Chỉ được sửa **data và script**, KHÔNG được sửa backend hoặc frontend.

## Question Types và MatchPairs Format

### 1. MATCHING_HEADING
```sql
MatchPairs: '{"section-a-q1": ["i. Full heading text"]}'::jsonb
```
- ⚠️ PHẢI chứa **FULL LABEL** (ví dụ: "i. The beginning of the Archaic period")
- KHÔNG chỉ chứa value ("i")

### 2. MATCHING_FEATURES  
```sql
MatchPairs: '{"feature-q6": ["C. Full option text"]}'::jsonb
```
- ⚠️ PHẢI chứa **FULL LABEL**

### 3. MATCHING_INFORMATION
```sql
MatchPairs: '{"paragraph": ["I"]}'::jsonb
```
- Chứa paragraph letter

### 4. YES_NO_NOT_GIVEN / TRUE_FALSE_NOT_GIVEN
- MatchPairs: NULL
- Dùng exam_options với IsCorrect flag

### 5. MULTIPLE_CHOICE_SINGLE
- MatchPairs: NULL  
- Dùng exam_options với IsCorrect flag

### 6. SUMMARY_COMPLETION
```sql
BlankAcceptTexts: '{"blank1": ["answer1", "answer2"]}'::jsonb
```

## Indexing Rules
- Idx bắt đầu từ 1 và PHẢI unique trong exam
- MC questions bắt đầu sau dropdown questions

## Scripts
- `crawler-ieltswriting.py`: Crawl từ ielts-writing.info
- `crawler-miniielts.py`: Crawl từ mini-ielts.com (deprecated)
- `run_seed.sh`: Seed database từ SQL files
