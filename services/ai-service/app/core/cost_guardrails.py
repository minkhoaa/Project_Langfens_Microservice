"""Cost guardrails for AI service - tracking, rate limiting, and fallback mechanisms."""

import logging
import time
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum
from typing import Any

logger = logging.getLogger(__name__)


class FallbackLevel(Enum):
    """Fallback level based on cost threshold."""
    NORMAL = "normal"
    DEGRADED = "degraded"
    FALLBACK = "fallback"


@dataclass
class CostRecord:
    """Record of a single API call cost."""
    timestamp: datetime
    operation: str
    cost: float
    success: bool


@dataclass
class CostTracker:
    """
    Tracks API costs per submission.
    
    Tracks all AI API calls and calculates cumulative cost per user/submission.
    """
    records: list[CostRecord] = field(default_factory=list)
    _cumulative_cost: float = 0.0
    
    def add_call(self, operation: str, cost: float, success: bool = True) -> None:
        """Record an API call with its cost."""
        record = CostRecord(
            timestamp=datetime.utcnow(),
            operation=operation,
            cost=cost,
            success=success
        )
        self.records.append(record)
        if success:
            self._cumulative_cost += cost
        logger.info(
            "AI API call tracked: operation=%s cost=%.6f success=%s cumulative=%.6f",
            operation, cost, success, self._cumulative_cost
        )
    
    @property
    def total_cost(self) -> float:
        """Get total cost of all successful calls."""
        return self._cumulative_cost
    
    @property
    def call_count(self) -> int:
        """Get total number of calls."""
        return len(self.records)
    
    def get_fallback_level(self, threshold: float = 0.50) -> FallbackLevel:
        """
        Determine fallback level based on cumulative cost.
        
        Args:
            threshold: Cost threshold per submission in dollars (default $0.50)
            
        Returns:
            FallbackLevel indicating current service mode
        """
        if self._cumulative_cost >= threshold:
            return FallbackLevel.FALLBACK
        elif self._cumulative_cost >= threshold * 0.7:
            return FallbackLevel.DEGRADED
        return FallbackLevel.NORMAL
    
    def should_use_fallback(self, threshold: float = 0.50) -> bool:
        """Check if fallback response should be used."""
        return self.get_fallback_level(threshold) == FallbackLevel.FALLBACK
    
    def reset(self) -> None:
        """Reset all cost tracking."""
        self.records.clear()
        self._cumulative_cost = 0.0
        logger.info("Cost tracker reset")


@dataclass
class RateLimiter:
    """
    Token bucket rate limiter for API calls.
    
    Limits requests to prevent quota exhaustion.
    """
    requests_per_minute: int = 100
    _requests: list[float] = field(default_factory=list)
    
    def __post_init__(self) -> None:
        """Initialize with default rate limit."""
        self.window_size = 60.0  # 1 minute window in seconds
    
    def is_allowed(self) -> tuple[bool, dict[str, Any]]:
        """
        Check if request is allowed under rate limit.
        
        Returns:
            Tuple of (allowed: bool, info: dict with rate limit status)
        """
        now = time.time()
        # Remove requests outside the window
        cutoff = now - self.window_size
        self._requests = [req_time for req_time in self._requests if req_time > cutoff]
        
        current_count = len(self._requests)
        remaining = max(0, self.requests_per_minute - current_count)
        
        info = {
            "current": current_count,
            "limit": self.requests_per_minute,
            "remaining": remaining,
            "reset_in": self.window_size - (now - self._requests[0]) if self._requests else 0
        }
        
        if current_count >= self.requests_per_minute:
            logger.warning(
                "Rate limit exceeded: current=%d limit=%d",
                current_count, self.requests_per_minute
            )
            return False, info
        
        # Record this request
        self._requests.append(now)
        return True, info
    
    def get_status(self) -> dict[str, Any]:
        """Get current rate limit status."""
        now = time.time()
        cutoff = now - self.window_size
        current_count = len([t for t in self._requests if t > cutoff])
        
        return {
            "current": current_count,
            "limit": self.requests_per_minute,
            "remaining": max(0, self.requests_per_minute - current_count),
            "window_seconds": self.window_size
        }
    
    def reset(self) -> None:
        """Reset rate limiter."""
        self._requests.clear()
        logger.info("Rate limiter reset")


class CostGuardrails:
    """
    Combined cost tracking, rate limiting, and fallback logic.
    
    This is the main entry point for cost guardrail operations.
    """
    
    def __init__(
        self,
        cost_per_submission_threshold: float = 0.50,
        requests_per_minute: int = 100
    ):
        """
        Initialize cost guardrails.
        
        Args:
            cost_per_submission_threshold: Maximum cost per submission in dollars
            requests_per_minute: Maximum requests per minute across all users
        """
        self.cost_tracker = CostTracker()
        self.rate_limiter = RateLimiter(requests_per_minute=requests_per_minute)
        self.cost_threshold = cost_per_submission_threshold
    
    def check_rate_limit(self) -> tuple[bool, dict[str, Any]]:
        """
        Check if request is allowed under rate limit.
        
        Returns:
            Tuple of (allowed: bool, info: dict)
        """
        return self.rate_limiter.is_allowed()
    
    def record_api_call(
        self,
        operation: str,
        cost: float,
        success: bool = True
    ) -> FallbackLevel:
        """
        Record an API call and return current fallback level.
        
        Args:
            operation: Name of the AI operation (e.g., 'gemini-chat', 'embedding')
            cost: Cost of the API call in dollars
            success: Whether the call succeeded
            
        Returns:
            Current FallbackLevel after recording the call
        """
        self.cost_tracker.add_call(operation, cost, success)
        return self.cost_tracker.get_fallback_level(self.cost_threshold)
    
    def should_fallback(self) -> bool:
        """Check if fallback mode should be activated."""
        return self.cost_tracker.should_use_fallback(self.cost_threshold)
    
    def get_fallback_level(self) -> FallbackLevel:
        """Get current fallback level."""
        return self.cost_tracker.get_fallback_level(self.cost_threshold)
    
    def get_status(self) -> dict[str, Any]:
        """Get comprehensive status of all guardrails."""
        return {
            "cost": {
                "total": self.cost_tracker.total_cost,
                "calls": self.cost_tracker.call_count,
                "threshold": self.cost_threshold,
                "level": self.get_fallback_level().value
            },
            "rate_limit": self.rate_limiter.get_status()
        }
    
    def reset(self) -> None:
        """Reset all guardrails."""
        self.cost_tracker.reset()
        self.rate_limiter.reset()
        logger.info("All cost guardrails reset")


# Global instance for use across the application
_guardrails: CostGuardrails | None = None


def get_guardrails() -> CostGuardrails:
    """Get or create the global guardrails instance."""
    global _guardrails
    if _guardrails is None:
        _guardrails = CostGuardrails()
    return _guardrails


def reset_guardrails() -> None:
    """Reset the global guardrails instance (mainly for testing)."""
    global _guardrails
    if _guardrails is not None:
        _guardrails.reset()
