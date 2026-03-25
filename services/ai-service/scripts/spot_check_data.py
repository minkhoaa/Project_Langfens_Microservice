#!/usr/bin/env python3
"""
Spot-check script for m1_writing.jsonl training data.
Randomly samples 50 examples and validates data quality.
"""

import json
import random
import re
from pathlib import Path
from typing import Any

DATA_FILE = "/home/khoa/dataset_ielts/export/finetune/m1_writing.jsonl"
SAMPLE_SIZE = 50
OUTPUT_REPORT = "docs/superpowers/reports/data-quality-spot-check.md"


def load_jsonl(path: str) -> list[dict]:
    """Load JSONL file and return list of records."""
    records = []
    with open(path, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError as e:
                print(f"  [MALFORMED JSON] Line {line_num}: {e}")
    return records


def extract_text_from_contents(contents: list) -> str:
    """Extract combined text from contents array ( Gemini format )."""
    texts = []
    for item in contents:
        if isinstance(item, dict) and "parts" in item:
            for part in item["parts"]:
                if isinstance(part, dict) and "text" in part:
                    texts.append(part["text"])
    return "\n".join(texts)


def extract_band_score(text: str) -> float | None:
    """Extract band score from response text using regex."""
    patterns = [
        r"Overall Band:\s*(\d+\.?\d*)",
        r"Band:\s*(\d+\.?\d*)",
        r"(\d+\.?\d*)\s*out of\s*\d+",
    ]
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            return float(match.group(1))
    return None


def validate_record(record: dict, idx: int) -> dict[str, Any]:
    """Validate a single record and return issues found."""
    issues = []
    warnings = []
    
    # Check for 'contents' field (Gemini format)
    if "contents" not in record:
        issues.append("Missing 'contents' field")
        return {"valid": False, "issues": issues, "warnings": warnings, "record_idx": idx}
    
    contents = record["contents"]
    if not isinstance(contents, list):
        issues.append(f"'contents' is not a list, got {type(contents)}")
        return {"valid": False, "issues": issues, "warnings": warnings, "record_idx": idx}
    
    if len(contents) < 2:
        issues.append(f"'contents' has fewer than 2 items (user + model)")
        return {"valid": False, "issues": issues, "warnings": warnings, "record_idx": idx}
    
    # Check user message
    user_content = contents[0] if len(contents) > 0 else {}
    model_content = contents[1] if len(contents) > 1 else {}
    
    user_text = extract_text_from_contents([user_content]) if user_content else ""
    model_text = extract_text_from_contents([model_content]) if model_content else ""
    
    # Check for empty input
    if not user_text or not user_text.strip():
        issues.append("User input (contents[0]) is empty")
    
    # Check for empty target (model response)
    if not model_text or not model_text.strip():
        issues.append("Model response (contents[1]) is empty")
    
    # Check content lengths
    if user_text and len(user_text) < 50:
        warnings.append(f"User input seems very short ({len(user_text)} chars)")
    
    if model_text and len(model_text) < 20:
        warnings.append(f"Model response seems very short ({len(model_text)} chars)")
    
    # Extract and validate band score
    band_score = extract_band_score(model_text)
    if band_score is None:
        warnings.append("Could not extract band score from model response")
    elif band_score < 1.0 or band_score > 9.0:
        issues.append(f"Band score {band_score} is outside valid range (1.0-9.0)")
    
    # Check for common issues
    if "Essay:" in user_text and "Essay:" not in user_text.split("Essay:")[1][:10]:
        pass  # OK - has essay
    
    return {
        "valid": len(issues) == 0,
        "issues": issues,
        "warnings": warnings,
        "record_idx": idx,
        "band_score": band_score,
        "user_text_len": len(user_text),
        "model_text_len": len(model_text),
        "user_preview": user_text[:200] + "..." if len(user_text) > 200 else user_text,
        "model_preview": model_text[:300] + "..." if len(model_text) > 300 else model_text,
    }


def main():
    print(f"Loading data from: {DATA_FILE}")
    all_records = load_jsonl(DATA_FILE)
    print(f"Total records in file: {len(all_records)}")
    
    if len(all_records) < SAMPLE_SIZE:
        print(f"Warning: File has fewer records ({len(all_records)}) than sample size ({SAMPLE_SIZE})")
        sample_indices = list(range(len(all_records)))
    else:
        sample_indices = random.sample(range(len(all_records)), SAMPLE_SIZE)
    
    print(f"Sampling {len(sample_indices)} random examples...")
    
    results = []
    for idx in sample_indices:
        record = all_records[idx]
        validation = validate_record(record, idx)
        results.append(validation)
    
    # Compile statistics
    valid_count = sum(1 for r in results if r["valid"])
    invalid_count = len(results) - valid_count
    
    all_issues = []
    all_warnings = []
    band_scores = []
    
    for r in results:
        all_issues.extend([(r["record_idx"], i) for i in r["issues"]])
        all_warnings.extend([(r["record_idx"], w) for w in r["warnings"]])
        if r["band_score"] is not None:
            band_scores.append(r["band_score"])
    
    # Generate report
    report = f"""# Data Quality Spot-Check Report: m1_writing.jsonl

**Date:** 2026-03-24  
**File:** `{DATA_FILE}`  
**Total Records:** {len(all_records):,}  
**Sample Size:** {SAMPLE_SIZE}  

---

## Summary

| Metric | Value |
|--------|-------|
| Sample Size | {SAMPLE_SIZE} |
| Valid Records | {valid_count} ({100*valid_count/SAMPLE_SIZE:.1f}%) |
| Invalid Records | {invalid_count} ({100*invalid_count/SAMPLE_SIZE:.1f}%) |
| Total Issues Found | {len(all_issues)} |
| Total Warnings | {len(all_warnings)} |

---

## Data Format

The file uses **Gemini API format** with `contents` array containing:
- `contents[0]`: User message (prompt with essay to analyze)
- `contents[1]`: Model response (band feedback)

Each message contains `role` and `parts` with `text` field.

---

## Issues Found

"""
    
    if not all_issues:
        report += "✅ **No critical issues found in sample!**\n\n"
    else:
        issue_counts = {}
        for _, issue in all_issues:
            issue_counts[issue] = issue_counts.get(issue, 0) + 1
        
        report += "### Issue Summary\n\n"
        for issue, count in sorted(issue_counts.items(), key=lambda x: -x[1]):
            report += f"- **{issue}**: {count} occurrences\n"
        
        report += "\n### Detailed Issues\n\n"
        for record_idx, issue in all_issues[:20]:  # Show first 20
            report += f"- Record #{record_idx}: {issue}\n"
        if len(all_issues) > 20:
            report += f"\n_... and {len(all_issues) - 20} more issues_\n"

    report += """
---

## Warnings

"""
    
    if not all_warnings:
        report += "✅ **No warnings in sample!**\n\n"
    else:
        warning_counts = {}
        for _, warning in all_warnings:
            warning_counts[warning] = warning_counts.get(warning, 0) + 1
        
        report += "### Warning Summary\n\n"
        for warning, count in sorted(warning_counts.items(), key=lambda x: -x[1]):
            report += f"- **{warning}**: {count} occurrences\n"
        
        report += "\n### Detailed Warnings\n\n"
        for record_idx, warning in all_warnings[:10]:  # Show first 10
            report += f"- Record #{record_idx}: {warning}\n"
        if len(all_warnings) > 10:
            report += f"\n_... and {len(all_warnings) - 10} more warnings_\n"

    report += f"""
---

## Band Score Distribution (in sample)

"""
    
    if band_scores:
        report += f"| Statistic | Value |\n|-----------|-------|\n"
        report += f"| Min | {min(band_scores):.1f} |\n"
        report += f"| Max | {max(band_scores):.1f} |\n"
        report += f"| Mean | {sum(band_scores)/len(band_scores):.2f} |\n"
        report += f"| Count | {len(band_scores)} |\n"
    else:
        report += "_No valid band scores extracted_\n"

    report += """
---

## Sample Examples

### Example 1: Valid Record

```
Record structure:
{
  "contents": [
    {"role": "user", "parts": [{"text": "Analyze this IELTS TASK_1 essay..."}]},
    {"role": "model", "parts": [{"text": "Overall Band: 8.0\n\nTask Response..."}]}
  ]
}
```

### Example 2: Record with Warning (short content)

"""
    
    short_records = [r for r in results if r["warnings"] and "short" in str(r["warnings"]).lower()]
    if short_records:
        r = short_records[0]
        report += f"""```
Record #{r["record_idx"]}:
- User text length: {r["user_text_len"]} chars
- Model text length: {r["model_text_len"]} chars
- User preview: {r["user_preview"][:100]}...
```"""

    report += """

---

## Recommendations

"""
    
    if invalid_count == 0 and len(all_warnings) == 0:
        report += "✅ **Data quality is excellent!** No cleaning needed.\n"
    elif invalid_count > 0:
        report += f"""1. **Critical:** {invalid_count} records have structural issues (missing/invalid fields)
   - Review and fix before training
2. Check records with missing essays in user input
3. Validate JSONL formatting for all records
"""
    else:
        report += f"""1. Consider reviewing {len(all_warnings)} warnings
2. Most warnings are informational - data is usable
3. No blocking issues found
"""

    report += f"""

---

## Methodology

- Random sample of {SAMPLE_SIZE} records using `random.sample()`
- Each record validated for:
  - Presence of required `contents` field
  - Minimum 2 items in contents (user + model)
  - Non-empty user input text
  - Non-empty model response text
  - Valid band score extraction (1.0-9.0 range)
- Band score extracted using regex patterns on model response

---

_Report generated by `spot_check_data.py`_
"""

    # Write report
    report_path = Path(OUTPUT_REPORT)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(report, encoding="utf-8")
    print(f"\nReport written to: {OUTPUT_REPORT}")
    
    # Print summary to console
    print("\n" + "="*60)
    print("SPOT-CHECK SUMMARY")
    print("="*60)
    print(f"Total records: {len(all_records):,}")
    print(f"Sample size: {SAMPLE_SIZE}")
    print(f"Valid: {valid_count} ({100*valid_count/SAMPLE_SIZE:.1f}%)")
    print(f"Invalid: {invalid_count} ({100*invalid_count/SAMPLE_SIZE:.1f}%)")
    print(f"Issues: {len(all_issues)}")
    print(f"Warnings: {len(all_warnings)}")
    if band_scores:
        print(f"Band score range: {min(band_scores):.1f} - {max(band_scores):.1f}")
    print("="*60)


if __name__ == "__main__":
    main()
