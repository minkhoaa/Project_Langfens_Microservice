# Evaluation Metrics for AI Grading
#
# Statistical metrics for evaluating AI grading quality against ground truth.

from dataclasses import dataclass, field
from typing import Optional
import math


@dataclass
class CriterionMetrics:
    """Metrics for a single grading criterion."""
    criterion: str
    mae: float  # Mean absolute error
    correct_direction: int  # Number of predictions within 0.5 of ground truth
    total: int


@dataclass
class EvalResult:
    """Complete evaluation result for a single essay."""
    essay_id: str
    predicted_overall: Optional[float]
    actual_overall: float
    overall_mae: Optional[float]
    criterion_metrics: dict[str, float]
    feedback_quality: float  # Score for feedback completeness/relevance
    error: Optional[str] = None


@dataclass
class AggregateMetrics:
    """Aggregate metrics across all evaluated essays."""
    num_evaluated: int
    num_total: int
    pearson_r: Optional[float]
    mae: float
    accuracy_within_half_band: float  # Percentage within 0.5 band of ground truth
    accuracy_within_one_band: float  # Percentage within 1.0 band of ground truth
    criterion_metrics: dict[str, CriterionMetrics]
    results: list[EvalResult] = field(default_factory=list)


def pearson_correlation(predictions: list[float], actuals: list[float]) -> Optional[float]:
    """
    Calculate Pearson correlation coefficient between predictions and actuals.
    
    Returns None if insufficient data or if standard deviation is zero.
    """
    n = len(predictions)
    if n < 2:
        return None
    
    # Calculate means
    mean_pred = sum(predictions) / n
    mean_actual = sum(actuals) / n
    
    # Calculate deviations and products
    numerator = 0.0
    sum_sq_pred = 0.0
    sum_sq_actual = 0.0
    
    for pred, actual in zip(predictions, actuals):
        if pred is None or actual is None:
            continue
        dev_pred = pred - mean_pred
        dev_actual = actual - mean_actual
        numerator += dev_pred * dev_actual
        sum_sq_pred += dev_pred * dev_pred
        sum_sq_actual += dev_actual * dev_actual
    
    # Handle zero standard deviation
    if sum_sq_pred == 0 or sum_sq_actual == 0:
        return None
    
    return numerator / math.sqrt(sum_sq_pred * sum_sq_actual)


def mean_absolute_error(predictions: list[float], actuals: list[float]) -> float:
    """Calculate mean absolute error between predictions and actuals."""
    valid_pairs = [(p, a) for p, a in zip(predictions, actuals) if p is not None and a is not None]
    if not valid_pairs:
        return float('inf')
    
    total_error = sum(abs(p - a) for p, a in valid_pairs)
    return total_error / len(valid_pairs)


def calculate_band_accuracy(predictions: list[float], actuals: list[float], threshold: float) -> float:
    """
    Calculate percentage of predictions within a given threshold of actual values.
    
    Args:
        predictions: List of predicted band scores
        actuals: List of actual band scores
        threshold: Maximum allowed difference (e.g., 0.5 or 1.0)
    
    Returns:
        Percentage (0-100) of predictions within threshold
    """
    valid_pairs = [(p, a) for p, a in zip(predictions, actuals) if p is not None and a is not None]
    if not valid_pairs:
        return 0.0
    
    within_threshold = sum(1 for p, a in valid_pairs if abs(p - a) <= threshold)
    return (within_threshold / len(valid_pairs)) * 100


def compute_metrics(results: list[EvalResult]) -> AggregateMetrics:
    """
    Compute aggregate metrics from a list of individual evaluation results.
    
    Args:
        results: List of EvalResult objects
    
    Returns:
        AggregateMetrics with computed statistics
    """
    # Separate successful evaluations from errors
    successful = [r for r in results if r.error is None and r.predicted_overall is not None]
    
    # Extract prediction and actual pairs
    predictions = [r.predicted_overall for r in successful]
    actuals = [r.actual_overall for r in successful]
    
    # Compute overall metrics
    pearson_r = pearson_correlation(predictions, actuals)
    mae = mean_absolute_error(predictions, actuals)
    accuracy_half = calculate_band_accuracy(predictions, actuals, 0.5)
    accuracy_one = calculate_band_accuracy(predictions, actuals, 1.0)
    
    # Compute per-criterion metrics
    criterion_metrics: dict[str, CriterionMetrics] = {}
    criterion_names = ["vocabulary", "coherence", "grammar", "task_response"]
    
    for criterion in criterion_names:
        pred_values = [r.criterion_metrics.get(criterion) for r in successful]
        actual_values = []
        for r in successful:
            if criterion == "vocabulary":
                actual_values.append(r.actual_overall - 0.0)  # Approximation
            elif criterion == "coherence":
                actual_values.append(r.actual_overall - 0.0)
            elif criterion == "grammar":
                actual_values.append(r.actual_overall - 0.0)
            elif criterion == "task_response":
                actual_values.append(r.actual_overall - 0.0)
        
        # Filter valid pairs
        valid_crit_pairs = [(p, a) for p, a in zip(pred_values, actual_values) 
                             if p is not None and a is not None]
        
        if valid_crit_pairs:
            crit_mae = mean_absolute_error([p for p, _ in valid_crit_pairs], 
                                            [a for _, a in valid_crit_pairs])
            correct_dir = sum(1 for p, a in valid_crit_pairs if abs(p - a) <= 0.5)
            criterion_metrics[criterion] = CriterionMetrics(
                criterion=criterion,
                mae=crit_mae,
                correct_direction=correct_dir,
                total=len(valid_crit_pairs)
            )
    
    return AggregateMetrics(
        num_evaluated=len(successful),
        num_total=len(results),
        pearson_r=pearson_r,
        mae=mae,
        accuracy_within_half_band=accuracy_half,
        accuracy_within_one_band=accuracy_one,
        criterion_metrics=criterion_metrics,
        results=results
    )


def format_metrics(metrics: AggregateMetrics) -> str:
    """Format aggregate metrics as a human-readable string."""
    lines = [
        "=" * 60,
        "AI GRADING EVALUATION RESULTS",
        "=" * 60,
        "",
        f"Evaluated: {metrics.num_evaluated}/{metrics.num_total} essays",
        "",
        "-" * 40,
        "OVERALL METRICS",
        "-" * 40,
    ]
    
    if metrics.pearson_r is not None:
        lines.append(f"Pearson Correlation: {metrics.pearson_r:.4f}")
    else:
        lines.append("Pearson Correlation: N/A (insufficient data)")
    
    lines.extend([
        f"Mean Absolute Error: {metrics.mae:.4f}",
        f"Accuracy (within 0.5 band): {metrics.accuracy_within_half_band:.1f}%",
        f"Accuracy (within 1.0 band): {metrics.accuracy_within_one_band:.1f}%",
        "",
        "-" * 40,
        "PER-CRITERION METRICS",
        "-" * 40,
    ])
    
    for criterion, crit_metrics in metrics.criterion_metrics.items():
        lines.append(f"\n{criterion.upper()}:")
        lines.append(f"  MAE: {crit_metrics.mae:.4f}")
        lines.append(f"  Accuracy (within 0.5): {crit_metrics.correct_direction}/{crit_metrics.total} ({crit_metrics.correct_direction/max(1,crit_metrics.total)*100:.1f}%)")
    
    lines.extend([
        "",
        "=" * 60,
    ])
    
    return "\n".join(lines)


def format_detailed_results(results: list[EvalResult]) -> str:
    """Format individual results as a detailed table."""
    lines = [
        "-" * 80,
        "INDIVIDUAL ESSAY RESULTS",
        "-" * 80,
        f"{'Essay ID':<20} {'Predicted':>10} {'Actual':>10} {'MAE':>10} {'Status':<20}",
        "-" * 80,
    ]
    
    for r in results:
        if r.error:
            lines.append(f"{r.essay_id:<20} {'N/A':>10} {r.actual_overall:>10.1f} {'N/A':>10} {'ERROR: ' + r.error:<20}")
        elif r.predicted_overall is not None:
            status = "✓ OK" if r.overall_mae is not None and r.overall_mae <= 0.5 else "⚠ Off target"
            lines.append(f"{r.essay_id:<20} {r.predicted_overall:>10.2f} {r.actual_overall:>10.1f} {r.overall_mae if r.overall_mae else 'N/A':>10} {status:<20}")
        else:
            lines.append(f"{r.essay_id:<20} {'N/A':>10} {r.actual_overall:>10.1f} {'N/A':>10} {'PENDING':<20}")
    
    return "\n".join(lines)
