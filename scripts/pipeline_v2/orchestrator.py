#!/usr/bin/env python3
"""
Pipeline V2 Complete Orchestrator
Runs full pipeline: 
Fetch → Clean → Parse → Normalize → Validate → Invariants → Repair → Export/Quarantine

Uses OLD CRAWLER functions for Parse and Export stages.
"""
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

from config import get_logger, detect_source, QUARANTINE_DIR

logger = get_logger(__name__)

# Import all stages
from fetch import fetch_and_save, extract_id
from clean import clean_and_save
from extract import extract_and_save
from normalize import normalize_and_save
from validate import validate
from invariants import check
from repair import repair
from export import export_sql


class PipelineResult:
    def __init__(self, url: str):
        self.url = url
        self.source = None
        self.item_id = None
        self.success = False
        self.stage_failed = None
        self.sql_path = None
        self.errors = []
        self.warnings = []
        self.repairs = []
    
    def fail(self, stage: str, error: str):
        self.success = False
        self.stage_failed = stage
        self.errors.append(f"[{stage}] {error}")
    
    def to_dict(self) -> dict:
        return {
            'url': self.url,
            'source': self.source,
            'item_id': self.item_id,
            'success': self.success,
            'stage_failed': self.stage_failed,
            'sql_path': str(self.sql_path) if self.sql_path else None,
            'errors': self.errors,
            'warnings': self.warnings,
            'repairs': self.repairs,
            'timestamp': datetime.now().isoformat(),
        }


def quarantine(result: PipelineResult) -> Path:
    """Move failed item to quarantine."""
    quarantine_dir = QUARANTINE_DIR / (result.source or 'unknown')
    quarantine_dir.mkdir(parents=True, exist_ok=True)
    
    report_path = quarantine_dir / f"{result.item_id or 'unknown'}.json"
    report_path.write_text(json.dumps(result.to_dict(), indent=2), encoding='utf-8')
    
    logger.warning(f"Quarantined: {report_path}")
    return report_path


def run_pipeline(url: str, use_ai: bool = True, skip_validation: bool = False) -> PipelineResult:
    """
    Run full pipeline for a single URL.
    
    Pipeline stages:
    1. Fetch - Download raw HTML
    2. Clean - Rule-based HTML cleaning
    3. Parse - Extract using old crawler functions
    4. Normalize - AI or rule-based normalization
    5. Validate - Schema gate
    6. Invariants - IELTS rules gate
    7. Repair - Auto-fix minor issues
    8. Export - Generate SQL
    """
    result = PipelineResult(url)
    
    logger.info("=" * 60)
    logger.info(f"PIPELINE V2 COMPLETE START: {url}")
    logger.info("=" * 60)
    
    # Detect source
    result.source = detect_source(url)
    if result.source == 'unknown':
        result.fail("DETECT", f"Unknown source for URL: {url}")
        quarantine(result)
        return result
    
    result.item_id = extract_id(url, result.source)
    logger.info(f"Source: {result.source}, Item ID: {result.item_id}")
    
    # === Stage 1: Fetch ===
    logger.info("Stage 1: FETCH - Downloading raw HTML...")
    fetch_result = fetch_and_save(url)
    if not fetch_result or not fetch_result.get('success'):
        result.fail("FETCH", fetch_result.get('error', 'Unknown error'))
        quarantine(result)
        return result
    logger.info("  ✓ Fetch complete")
    
    # === Stage 2: Clean ===
    logger.info("Stage 2: CLEAN - Rule-based cleaning...")
    clean_result = clean_and_save(result.source, result.item_id)
    if not clean_result:
        result.fail("CLEAN", "Cleaning failed")
        quarantine(result)
        return result
    logger.info(f"  ✓ Clean complete ({clean_result.get('word_count', 0)} words)")
    
    # === Stage 3: Parse (using old crawler) ===
    logger.info("Stage 3: PARSE - Extracting with old crawler...")
    extract_result = extract_and_save(result.source, result.item_id)
    if not extract_result:
        result.fail("PARSE", "Extraction failed")
        quarantine(result)
        return result
    logger.info(f"  ✓ Parse complete ({len(extract_result.get('questions', []))} questions)")
    
    # === Stage 4: Normalize ===
    ai_label = "with AI" if use_ai else "rule-based"
    logger.info(f"Stage 4: NORMALIZE - Converting to schema ({ai_label})...")
    normalize_result = normalize_and_save(result.source, result.item_id, use_ai)
    if not normalize_result:
        result.fail("NORMALIZE", "Normalization failed")
        quarantine(result)
        return result
    method = normalize_result.get('_metadata', {}).get('normalized_by', 'unknown')
    logger.info(f"  ✓ Normalize complete ({method})")
    
    if not skip_validation:
        # === Stage 5: Validate (Schema Gate) ===
        logger.info("Stage 5: VALIDATE - Schema gate...")
        validation = validate(result.source, result.item_id)
        if not validation.is_valid():
            result.errors.extend(validation.errors)
            result.fail("VALIDATE", "Schema validation failed")
            quarantine(result)
            return result
        result.warnings.extend(validation.warnings)
        logger.info(f"  ✓ Schema valid ({len(validation.warnings)} warnings)")
        
        # === Stage 6: Invariants (IELTS Rules Gate) ===
        logger.info("Stage 6: INVARIANTS - IELTS rules gate...")
        invariants_result = check(result.source, result.item_id)
        if not invariants_result.is_valid():
            # Try repair before failing
            logger.info("  ⚠ Invariants failed, attempting repair...")
            
            # === Stage 7: Repair ===
            logger.info("Stage 7: REPAIR - Auto-fixing issues...")
            repaired_data, repair_result = repair(result.source, result.item_id)
            result.repairs.extend(repair_result.repairs_made)
            
            if repair_result.repairs_made:
                # Re-check invariants after repair
                invariants_result = check(result.source, result.item_id)
                if invariants_result.is_valid():
                    logger.info(f"  ✓ Repair fixed issues ({len(repair_result.repairs_made)} repairs)")
                else:
                    result.errors.extend(invariants_result.violations)
                    result.fail("INVARIANTS", "IELTS rules violated (after repair)")
                    quarantine(result)
                    return result
            else:
                result.errors.extend(invariants_result.violations)
                result.fail("INVARIANTS", "IELTS rules violated")
                quarantine(result)
                return result
        else:
            logger.info(f"  ✓ Invariants valid ({len(invariants_result.warnings)} warnings)")
            result.warnings.extend(invariants_result.warnings)
    else:
        logger.info("Stage 5-7: SKIPPED (skip_validation=True)")
    
    # === Stage 8: Export ===
    logger.info("Stage 8: EXPORT - Generating SQL...")
    sql_path = export_sql(result.source, result.item_id)
    if not sql_path:
        result.fail("EXPORT", "SQL export failed")
        quarantine(result)
        return result
    
    result.success = True
    result.sql_path = sql_path
    
    logger.info("=" * 60)
    logger.info(f"PIPELINE V2 SUCCESS: {url}")
    logger.info(f"Output: {sql_path}")
    logger.info("=" * 60)
    
    return result


# CLI
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python orchestrator.py <URL> [--no-ai] [--skip-validation]")
        print("       python orchestrator.py --batch <file.txt> [--no-ai] [--skip-validation]")
        sys.exit(1)
    
    use_ai = '--no-ai' not in sys.argv
    skip_validation = '--skip-validation' in sys.argv
    
    if sys.argv[1] == '--batch':
        # Batch mode
        if len(sys.argv) < 3:
            print("Batch mode requires a file with URLs")
            sys.exit(1)
        
        urls_file = Path(sys.argv[2])
        urls = [line.strip() for line in urls_file.read_text().splitlines() if line.strip()]
        
        success = 0
        for url in urls:
            result = run_pipeline(url, use_ai, skip_validation)
            if result.success:
                success += 1
                print(f"✓ {url}")
            else:
                print(f"✗ {url}: {result.stage_failed}")
        
        print(f"\nCompleted: {success}/{len(urls)} succeeded")
    else:
        # Single URL mode
        url = sys.argv[1]
        result = run_pipeline(url, use_ai, skip_validation)
        
        if result.success:
            print(f"\n✓ Pipeline completed successfully!")
            print(f"  SQL: {result.sql_path}")
            if result.repairs:
                print(f"  Repairs: {len(result.repairs)}")
            if result.warnings:
                print(f"  Warnings: {len(result.warnings)}")
        else:
            print(f"\n✗ Pipeline failed at stage: {result.stage_failed}")
            for error in result.errors:
                print(f"  • {error}")
            sys.exit(1)
