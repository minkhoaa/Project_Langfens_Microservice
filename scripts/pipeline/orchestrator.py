#!/usr/bin/env python3
"""
Pipeline Orchestrator
Runs full pipeline: Fetch → Clean → Parse → Normalize → Validate → Export
"""
import sys
from pathlib import Path
from typing import Optional

from config import get_logger, QUARANTINE_DIR
from fetcher import fetch_and_save, identify_source, extract_id
from cleaner import clean_and_save
from parser import parse_and_save
from normalizer import normalize_and_save
from validator import validate_file
from invariants import validate_file as check_invariants
from exporter import export_to_sql

logger = get_logger(__name__)


class PipelineResult:
    def __init__(self, url: str):
        self.url = url
        self.source = None
        self.item_id = None
        self.success = False
        self.stage_failed = None
        self.errors = []
        self.warnings = []
        self.output_sql = None
        self.output_json = None
    
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
            'errors': self.errors,
            'warnings': self.warnings,
            'output_sql': str(self.output_sql) if self.output_sql else None,
            'output_json': str(self.output_json) if self.output_json else None,
        }


def run_pipeline(url: str, skip_validation: bool = False) -> PipelineResult:
    """Run full pipeline for a single URL."""
    result = PipelineResult(url)
    
    logger.info("=" * 60)
    logger.info(f"PIPELINE START: {url}")
    logger.info("=" * 60)
    
    # Stage 1: Fetch
    logger.info("Stage 1: Fetching...")
    raw_path = fetch_and_save(url)
    if not raw_path:
        result.fail("FETCH", "Failed to fetch URL")
        return result
    
    result.source = identify_source(url)
    result.item_id = extract_id(url, result.source)
    
    # Stage 2: Clean
    logger.info("Stage 2: Cleaning...")
    cleaned_path = clean_and_save(result.source, result.item_id)
    if not cleaned_path:
        result.fail("CLEAN", "Failed to clean HTML")
        return result
    
    # Stage 3: Parse
    logger.info("Stage 3: Parsing...")
    parsed_path = parse_and_save(result.source, result.item_id)
    if not parsed_path:
        result.fail("PARSE", "Failed to parse content")
        return result
    
    # Stage 4: Normalize
    logger.info("Stage 4: Normalizing...")
    normalized_path = normalize_and_save(result.source, result.item_id)
    if not normalized_path:
        result.fail("NORMALIZE", "Failed to normalize data")
        return result
    
    if not skip_validation:
        # Stage 5: Validate Schema
        logger.info("Stage 5: Validating schema...")
        validation = validate_file(result.source, result.item_id)
        if not validation.is_valid():
            result.errors.extend(validation.errors)
            result.fail("VALIDATE", "Schema validation failed")
            quarantine(result)
            return result
        result.warnings.extend(validation.warnings)
        
        # Stage 6: Check Invariants
        logger.info("Stage 6: Checking invariants...")
        invariants = check_invariants(result.source, result.item_id)
        if not invariants.is_valid():
            result.errors.extend(invariants.violations)
            result.fail("INVARIANTS", "IELTS invariants violated")
            quarantine(result)
            return result
        result.warnings.extend(invariants.warnings)
    
    # Stage 8: Export
    logger.info("Stage 8: Exporting...")
    sql_path = export_to_sql(result.source, result.item_id)
    if not sql_path:
        result.fail("EXPORT", "Failed to export SQL")
        return result
    
    result.success = True
    result.output_sql = sql_path
    
    logger.info("=" * 60)
    logger.info(f"PIPELINE SUCCESS: {url}")
    logger.info(f"Output: {sql_path}")
    logger.info("=" * 60)
    
    return result


def quarantine(result: PipelineResult):
    """Move failed item to quarantine."""
    import json
    quarantine_dir = QUARANTINE_DIR / result.source
    quarantine_dir.mkdir(parents=True, exist_ok=True)
    
    report_path = quarantine_dir / f"{result.item_id}.json"
    report_path.write_text(json.dumps(result.to_dict(), indent=2), encoding='utf-8')
    
    logger.warning(f"Quarantined: {report_path}")


def run_batch(urls: list[str], skip_validation: bool = False) -> list[PipelineResult]:
    """Run pipeline for multiple URLs."""
    results = []
    for url in urls:
        result = run_pipeline(url, skip_validation)
        results.append(result)
    
    # Summary
    success = sum(1 for r in results if r.success)
    failed = len(results) - success
    logger.info(f"\n{'=' * 60}")
    logger.info(f"BATCH COMPLETE: {success} success, {failed} failed")
    logger.info("=" * 60)
    
    return results


# CLI
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python orchestrator.py <URL> [--skip-validation]")
        print("       python orchestrator.py --batch <file.txt> [--skip-validation]")
        sys.exit(1)
    
    skip_validation = '--skip-validation' in sys.argv
    
    if sys.argv[1] == '--batch':
        # Batch mode
        if len(sys.argv) < 3:
            print("Batch mode requires a file with URLs")
            sys.exit(1)
        
        urls_file = Path(sys.argv[2])
        urls = [line.strip() for line in urls_file.read_text().splitlines() if line.strip()]
        results = run_batch(urls, skip_validation)
        
        for r in results:
            status = "✓" if r.success else "✗"
            print(f"{status} {r.url}")
    else:
        # Single URL mode
        url = sys.argv[1]
        result = run_pipeline(url, skip_validation)
        
        if result.success:
            print(f"\n✓ Pipeline completed successfully!")
            print(f"  SQL: {result.output_sql}")
        else:
            print(f"\n✗ Pipeline failed at stage: {result.stage_failed}")
            for error in result.errors:
                print(f"  • {error}")
            sys.exit(1)
