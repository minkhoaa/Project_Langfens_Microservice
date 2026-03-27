#!/usr/bin/env python3
"""
AI Grading Evaluation Harness

Command-line tool to evaluate AI grading quality using a golden dataset.

Usage:
    python -m eval.harness --sample-size=5
    python -m eval.harness --essay-id=band6_education_01
    python -m eval.harness --list
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Optional

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from app.eval.golden_dataset import (
    GOLDEN_DATASET,
    GoldenEssay,
    get_essays_by_band,
    get_sample,
)
from app.eval.metrics import (
    EvalResult,
    compute_metrics,
    format_detailed_results,
    format_metrics,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


# =============================================================================
# Gemini Grading Integration
# =============================================================================

async def call_gemini_grading(
    essay: GoldenEssay,
    api_key: Optional[str] = None
) -> dict:
    """
    Call Gemini API to grade an essay.
    
    Args:
        essay: The golden essay to grade
        api_key: Optional API key (will use environment variable if not provided)
    
    Returns:
        Dictionary with grading results including predicted_band and feedback
    """
    try:
        import os
        from google import genai
        
        if api_key is None:
            api_key = os.environ.get("GEMINI_API_KEY")
        
        if not api_key:
            raise ValueError("GEMINI_API_KEY not set")
        
        client = genai.Client(api_key=api_key)
        
        prompt = f"""You are an expert IELTS writing examiner. Grade the following IELTS essay.

Essay Question:
{essay.topic}

Essay to Grade:
{essay.essay_text}

Provide your grading in JSON format with these fields:
- overall_band: A number between 1 and 9 (e.g., 6.5)
- vocabulary: A number between 1 and 9 
- coherence: A number between 1 and 9
- grammar: A number between 1 and 9
- task_response: A number between 1 and 9
- feedback: Detailed feedback on strengths and weaknesses
- suggestions: Specific suggestions for improvement

Respond ONLY with valid JSON, no additional text."""

        response = client.models.generate_content(
            model="gemini-2.0-flash",
            contents=prompt
        )
        
        # Parse JSON response
        import re
        json_match = re.search(r'\{.*\}', response.text, re.DOTALL)
        if json_match:
            result = json.loads(json_match.group())
            return result
        else:
            raise ValueError(f"Could not parse JSON from response: {response.text}")
    
    except Exception as e:
        logger.error(f"Error calling Gemini API: {e}")
        raise


def grade_essay_mock(essay: GoldenEssay) -> dict:
    """
    Mock grading function for testing without API calls.
    
    Adds small random variation to the ground truth to simulate AI grading.
    """
    import random
    random.seed(essay.essay_id)  # Deterministic for testing
    
    # Add small random variation
    variation = random.uniform(-0.5, 0.5)
    predicted = essay.overall_band + variation
    
    return {
        "overall_band": round(predicted, 1),
        "vocabulary": round(essay.breakdown.vocabulary + random.uniform(-0.3, 0.3), 1),
        "coherence": round(essay.breakdown.coherence + random.uniform(-0.3, 0.3), 1),
        "grammar": round(essay.breakdown.grammar + random.uniform(-0.3, 0.3), 1),
        "task_response": round(essay.breakdown.task_response + random.uniform(-0.3, 0.3), 1),
        "feedback": f"Mock feedback for {essay.essay_id}. The essay shows {'good' if essay.overall_band >= 7 else 'adequate'} development.",
        "suggestions": "Consider improving vocabulary range and coherence."
    }


async def grade_essay(
    essay: GoldenEssay,
    use_mock: bool = False,
    api_key: Optional[str] = None
) -> EvalResult:
    """
    Grade a single essay and return evaluation result.
    
    Args:
        essay: The golden essay to grade
        use_mock: If True, use mock grading (for testing)
        api_key: Optional Gemini API key
    
    Returns:
        EvalResult with predicted and actual scores
    """
    try:
        if use_mock:
            result = grade_essay_mock(essay)
        else:
            result = await call_gemini_grading(essay, api_key)
        
        predicted_band = result.get("overall_band")
        if predicted_band is None:
            return EvalResult(
                essay_id=essay.essay_id,
                predicted_overall=None,
                actual_overall=essay.overall_band,
                overall_mae=None,
                criterion_metrics={},
                feedback_quality=0.0,
                error="No overall_band in response"
            )
        
        # Calculate MAE for overall band
        mae = abs(predicted_band - essay.overall_band) if predicted_band else None
        
        # Extract criterion metrics
        criterion_metrics = {
            "vocabulary": result.get("vocabulary"),
            "coherence": result.get("coherence"),
            "grammar": result.get("grammar"),
            "task_response": result.get("task_response"),
        }
        
        # Feedback quality score (placeholder - could be enhanced with NLP)
        feedback = result.get("feedback", "")
        feedback_quality = 1.0 if len(feedback) > 50 else 0.5
        
        return EvalResult(
            essay_id=essay.essay_id,
            predicted_overall=predicted_band,
            actual_overall=essay.overall_band,
            overall_mae=mae,
            criterion_metrics=criterion_metrics,
            feedback_quality=feedback_quality
        )
    
    except Exception as e:
        logger.error(f"Error grading essay {essay.essay_id}: {e}")
        return EvalResult(
            essay_id=essay.essay_id,
            predicted_overall=None,
            actual_overall=essay.overall_band,
            overall_mae=None,
            criterion_metrics={},
            feedback_quality=0.0,
            error=str(e)
        )


async def run_evaluation(
    essays: list[GoldenEssay],
    use_mock: bool = False,
    api_key: Optional[str] = None,
    output_file: Optional[str] = None
) -> dict:
    """
    Run evaluation on a list of essays.
    
    Args:
        essays: List of golden essays to evaluate
        use_mock: If True, use mock grading
        api_key: Optional Gemini API key
        output_file: Optional path to write JSON results
    
    Returns:
        Dictionary with evaluation results
    """
    logger.info(f"Evaluating {len(essays)} essays...")
    
    results = []
    for essay in essays:
        logger.info(f"Grading essay: {essay.essay_id}")
        result = await grade_essay(essay, use_mock=use_mock, api_key=api_key)
        results.append(result)
        
        if result.predicted_overall is not None:
            logger.info(
                f"  {essay.essay_id}: predicted={result.predicted_overall:.1f}, "
                f"actual={result.actual_overall:.1f}, mae={result.overall_mae:.2f}"
            )
        else:
            logger.warning(f"  {essay.essay_id}: ERROR - {result.error}")
    
    # Compute aggregate metrics
    metrics = compute_metrics(results)
    
    # Print results
    print("\n" + format_metrics(metrics))
    print("\n" + format_detailed_results(results))
    
    # Write JSON output if requested
    if output_file:
        output_data = {
            "metrics": {
                "num_evaluated": metrics.num_evaluated,
                "num_total": metrics.num_total,
                "pearson_r": metrics.pearson_r,
                "mae": metrics.mae,
                "accuracy_within_half_band": metrics.accuracy_within_half_band,
                "accuracy_within_one_band": metrics.accuracy_within_one_band,
            },
            "results": [
                {
                    "essay_id": r.essay_id,
                    "predicted_overall": r.predicted_overall,
                    "actual_overall": r.actual_overall,
                    "overall_mae": r.overall_mae,
                    "criterion_metrics": r.criterion_metrics,
                    "feedback_quality": r.feedback_quality,
                    "error": r.error,
                }
                for r in results
            ]
        }
        
        with open(output_file, 'w') as f:
            json.dump(output_data, f, indent=2)
        
        logger.info(f"Results written to {output_file}")
    
    return {
        "metrics": metrics,
        "results": results
    }


# =============================================================================
# CLI Interface
# =============================================================================

def list_essays():
    """List all available essays in the golden dataset."""
    print("\nAvailable Essays in Golden Dataset:")
    print("-" * 80)
    print(f"{'Essay ID':<25} {'Band':>6} {'Question Type':<20} {'Word Count':>12}")
    print("-" * 80)
    
    for essay in GOLDEN_DATASET:
        word_count = len(essay.essay_text.split())
        print(f"{essay.essay_id:<25} {essay.overall_band:>6.1f} {essay.question_type:<20} {word_count:>12}")
    
    print("-" * 80)
    print(f"Total: {len(GOLDEN_DATASET)} essays")


def main():
    parser = argparse.ArgumentParser(
        description="AI Grading Evaluation Harness"
    )
    
    parser.add_argument(
        "--sample-size",
        type=int,
        default=None,
        help="Number of random essays to evaluate"
    )
    
    parser.add_argument(
        "--essay-id",
        type=str,
        default=None,
        help="Evaluate a specific essay by ID"
    )
    
    parser.add_argument(
        "--band",
        type=float,
        default=None,
        help="Evaluate essays from a specific band (6, 7, 8, or 9)"
    )
    
    parser.add_argument(
        "--list",
        action="store_true",
        help="List all available essays"
    )
    
    parser.add_argument(
        "--mock",
        action="store_true",
        help="Use mock grading (no API calls)"
    )
    
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Write JSON results to file"
    )
    
    parser.add_argument(
        "--api-key",
        type=str,
        default=None,
        help="Gemini API key (or set GEMINI_API_KEY env var)"
    )
    
    args = parser.parse_args()
    
    # List mode
    if args.list:
        list_essays()
        return
    
    # Determine which essays to evaluate
    essays = []
    
    if args.essay_id:
        # Single essay by ID
        for essay in GOLDEN_DATASET:
            if essay.essay_id == args.essay_id:
                essays = [essay]
                break
        else:
            print(f"Essay not found: {args.essay_id}")
            print("\nAvailable essays:")
            list_essays()
            return
    
    elif args.band:
        # Essays by band
        essays = get_essays_by_band(args.band)
        if not essays:
            print(f"No essays found for band {args.band}")
            return
    
    elif args.sample_size:
        # Random sample
        essays = get_sample(args.sample_size)
    
    else:
        # Default: evaluate all essays
        essays = GOLDEN_DATASET
    
    if not essays:
        print("No essays to evaluate. Use --list to see available essays.")
        return
    
    # Run evaluation
    import asyncio
    
    try:
        result = asyncio.run(
            run_evaluation(
                essays=essays,
                use_mock=args.mock,
                api_key=args.api_key,
                output_file=args.output
            )
        )
        
        # Return exit code based on results
        if result["metrics"].num_evaluated == 0:
            sys.exit(1)
        
        # Check if correlation is acceptable
        if result["metrics"].pearson_r is not None:
            if result["metrics"].pearson_r >= 0.7:
                print(f"\n✓ Grading quality acceptable (r={result['metrics'].pearson_r:.3f})")
                sys.exit(0)
            else:
                print(f"\n⚠ Grading quality needs improvement (r={result['metrics'].pearson_r:.3f})")
                sys.exit(1)
        
    except KeyboardInterrupt:
        print("\nEvaluation interrupted by user")
        sys.exit(130)
    except Exception as e:
        logger.error(f"Evaluation failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
