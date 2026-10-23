import hashlib
import json
import math
import os
from pathlib import Path

from pydantic import AliasChoices, Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

def cap_snapshot_json(snapshot: dict) -> str:
    """Canonical UTF-8 profile JSON shared with .NET's sorted, unescaped serializer."""
    return json.dumps(snapshot, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def cap_snapshot_sha256(snapshot: dict) -> str:
    return hashlib.sha256(cap_snapshot_json(snapshot).encode("utf-8")).hexdigest()


_repo_root = Path(__file__).resolve().parent.parent.parent.parent
_env_file_override = os.environ.get("GENERATION_SERVICE_ENV_FILE") or os.environ.get("AI_SERVICE_ENV_FILE")
_ai_env = _repo_root / "deploy" / "envs" / "ai.env"
_caps_env = _repo_root / "deploy" / "envs" / "loop-caps.env"
_env_files = [str(_caps_env)] if _caps_env.is_file() else []
if _env_file_override:
    _env_files.append(_env_file_override)
elif _ai_env.is_file():
    _env_files.append(str(_ai_env))
_default_env_files = tuple(_env_files) or None


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        extra="ignore",
        env_file=_default_env_files,
        env_file_encoding="utf-8",
        populate_by_name=True,
        allow_inf_nan=False,
        hide_input_in_errors=True,
    )

    environment: str = "development"
    port: int = 8080
    internal_api_key: str = Field(
        default="",
        validation_alias=AliasChoices(
            "EXAMSERVICE__INTERNAL__API__KEY",
            "INTERNAL_API_KEY",
            "internal_api_key",
            "InternalApiKey",
        ),
    )

    # MiniMax
    minimax_base_url: str = "https://api.minimaxi.chat/v1"
    minimax_model: str = "MiniMax-Text-01"
    minimax_api_key: str = ""
    minimax_api_keys: str = ""

    # Groq fallback
    groq_base_url: str = "https://api.groq.com/openai/v1"
    groq_model: str = "openai/gpt-oss-120b"
    groq_api_key: str = ""
    groq_api_keys: str = ""

    llm_provider_order: str = "minimax,groq"
    openalex_api_key: str = ""

    # Versioned G06 runtime profile. Production composition must inject its identity.
    loop_caps_profile_version: str = "development-unpinned"
    loop_caps_profile_source: str = "development defaults"
    benchmark_caps_mode: str = "LIMITED"
    benchmark_monetary_cap_mode: str = "LIMITED"
    loop_max_versions: int = 3
    loop_max_generated_versions: int = 3
    loop_max_repair_attempts_per_version: int = 2
    loop_max_total_repairs: int = 5
    loop_max_consecutive_no_progress: int = 2
    loop_max_oscillation_cycles: int = 2
    loop_max_total_calls: int = 15
    loop_max_total_tokens: int = 60_000
    loop_max_wall_time_seconds: int = 300
    loop_generate_token_reservation: int = 15_000
    loop_evaluate_token_reservation: int = 10_000
    loop_repair_token_reservation: int = 15_000
    loop_operation_wall_reservation_seconds: int = 60
    loop_max_response_bytes: int = 500_000
    passage_generate_token_reservation: int = 18000
    passage_generate_max_tokens: int = 2500
    loop_min_score_threshold: float = Field(default=0.8, ge=0.0, le=1.0)

    # Authoritative .NET legacy-run and campaign-child limits, from the same profile.
    reading_paper_run_budget_max_calls: int = 25
    reading_paper_run_budget_max_tokens: int = 150_000
    reading_paper_run_budget_max_wall_time_seconds: int = 900
    benchmark_child_run_max_calls: int = 15
    benchmark_child_run_max_tokens: int = 60_000
    benchmark_child_run_max_wall_time_seconds: int = 300

    legacy_section_token_cap: int = Field(default=45_000, validation_alias="READING_PAPER_LEGACY_SECTION_TOKEN_CAP")
    legacy_section_call_cap: int = Field(default=8, validation_alias="READING_PAPER_LEGACY_SECTION_CALL_CAP")
    legacy_section_wall_time_cap_seconds: int = Field(default=280, validation_alias="READING_PAPER_LEGACY_SECTION_WALL_TIME_CAP_SECONDS")
    legacy_passage_token_cap: int = Field(default=15_000, validation_alias="READING_PAPER_LEGACY_PASSAGE_TOKEN_CAP")
    legacy_passage_call_cap: int = Field(default=2, validation_alias="READING_PAPER_LEGACY_PASSAGE_CALL_CAP")
    legacy_passage_wall_time_cap_seconds: int = Field(default=90, validation_alias="READING_PAPER_LEGACY_PASSAGE_WALL_TIME_CAP_SECONDS")
    legacy_questions_token_cap: int = Field(default=18_000, validation_alias="READING_PAPER_LEGACY_QUESTIONS_TOKEN_CAP")
    legacy_questions_call_cap: int = Field(default=3, validation_alias="READING_PAPER_LEGACY_QUESTIONS_CALL_CAP")
    legacy_questions_wall_time_cap_seconds: int = Field(default=100, validation_alias="READING_PAPER_LEGACY_QUESTIONS_WALL_TIME_CAP_SECONDS")
    legacy_solver_token_cap: int = Field(default=6_000, validation_alias="READING_PAPER_LEGACY_SOLVER_TOKEN_CAP")
    legacy_solver_call_cap: int = Field(default=2, validation_alias="READING_PAPER_LEGACY_SOLVER_CALL_CAP")
    legacy_solver_wall_time_cap_seconds: int = Field(default=50, validation_alias="READING_PAPER_LEGACY_SOLVER_WALL_TIME_CAP_SECONDS")
    legacy_review_token_cap: int = Field(default=6_000, validation_alias="READING_PAPER_LEGACY_REVIEW_TOKEN_CAP")
    legacy_review_call_cap: int = Field(default=1, validation_alias="READING_PAPER_LEGACY_REVIEW_CALL_CAP")
    legacy_review_wall_time_cap_seconds: int = Field(default=40, validation_alias="READING_PAPER_LEGACY_REVIEW_WALL_TIME_CAP_SECONDS")
    benchmark_section_token_cap: int = Field(default=20_000, validation_alias="READING_PAPER_BENCHMARK_SECTION_TOKEN_CAP")
    benchmark_section_call_cap: int = Field(default=5, validation_alias="READING_PAPER_BENCHMARK_SECTION_CALL_CAP")
    benchmark_section_wall_time_cap_seconds: int = Field(default=100, validation_alias="READING_PAPER_BENCHMARK_SECTION_WALL_TIME_CAP_SECONDS")
    benchmark_passage_token_cap: int = Field(default=8_000, validation_alias="READING_PAPER_BENCHMARK_PASSAGE_TOKEN_CAP")
    benchmark_passage_call_cap: int = Field(default=1, validation_alias="READING_PAPER_BENCHMARK_PASSAGE_CALL_CAP")
    benchmark_passage_wall_time_cap_seconds: int = Field(default=35, validation_alias="READING_PAPER_BENCHMARK_PASSAGE_WALL_TIME_CAP_SECONDS")
    benchmark_questions_token_cap: int = Field(default=7_000, validation_alias="READING_PAPER_BENCHMARK_QUESTIONS_TOKEN_CAP")
    benchmark_questions_call_cap: int = Field(default=2, validation_alias="READING_PAPER_BENCHMARK_QUESTIONS_CALL_CAP")
    benchmark_questions_wall_time_cap_seconds: int = Field(default=35, validation_alias="READING_PAPER_BENCHMARK_QUESTIONS_WALL_TIME_CAP_SECONDS")
    benchmark_solver_token_cap: int = Field(default=3_000, validation_alias="READING_PAPER_BENCHMARK_SOLVER_TOKEN_CAP")
    benchmark_solver_call_cap: int = Field(default=1, validation_alias="READING_PAPER_BENCHMARK_SOLVER_CALL_CAP")
    benchmark_solver_wall_time_cap_seconds: int = Field(default=15, validation_alias="READING_PAPER_BENCHMARK_SOLVER_WALL_TIME_CAP_SECONDS")
    benchmark_review_token_cap: int = Field(default=2_000, validation_alias="READING_PAPER_BENCHMARK_REVIEW_TOKEN_CAP")
    benchmark_review_call_cap: int = Field(default=1, validation_alias="READING_PAPER_BENCHMARK_REVIEW_CALL_CAP")
    benchmark_review_wall_time_cap_seconds: int = Field(default=15, validation_alias="READING_PAPER_BENCHMARK_REVIEW_WALL_TIME_CAP_SECONDS")

    # Evaluator & Repair Caps (Phase 07)
    evaluator_deterministic_timeout_seconds: int = 5
    evaluator_semantic_timeout_seconds: int = 30
    evaluator_stage_timeout_seconds: int = 60
    evaluator_max_tokens_per_evaluation: int = 4000
    repair_timeout_seconds: int = 30
    repair_max_tokens_per_attempt: int = 3000
    enable_hybrid_repair: bool = True
    evaluation_cache_enabled: bool = True
    evaluation_cache_max_entries: int = 1000

    # Candidate Pool & Selection Caps (Phase 09 / P09-03)
    candidate_pool_limit_completion: int = 3
    candidate_pool_limit_tfng: int = 3
    candidate_pool_limit_mcq: int = 3
    candidate_pool_limit_summary: int = 3
    candidate_pool_limit_short_answer: int = 3
    candidate_max_search_depth: int = 50
    candidate_max_backtracking_steps: int = 5000

    @field_validator("loop_caps_profile_version", "loop_caps_profile_source")
    @classmethod
    def normalize_profile_identity(cls, value: str) -> str:
        return value.strip()

    @field_validator("*", mode="before")
    @classmethod
    def validate_integer_caps(cls, value, info):
        if info.field_name in cls.resource_cap_fields():
            if isinstance(value, bool):
                raise ValueError("Resource caps must be whole positive integers")
            int_val: int
            if isinstance(value, int):
                int_val = value
            elif isinstance(value, float):
                if value.is_integer() and math.isfinite(value):
                    int_val = int(value)
                else:
                    raise ValueError("Resource caps must be whole positive integers")
            elif isinstance(value, str):
                s = value.strip().lstrip("+")
                try:
                    int_val = int(s)
                except ValueError:
                    try:
                        f = float(s)
                        if f.is_integer() and math.isfinite(f):
                            int_val = int(f)
                        else:
                            raise ValueError("Resource caps must be whole positive integers")
                    except (ValueError, OverflowError):
                        raise ValueError("Resource caps must be whole positive integers")
            else:
                raise ValueError("Resource caps must be whole positive integers")

            if not 0 < int_val <= 2_147_483_647:
                raise ValueError("Resource caps must be positive 32-bit integers")
            return int_val
        return value

    @classmethod
    def resource_cap_fields(cls) -> tuple[str, ...]:
        return tuple(name for name, field in cls.model_fields.items()
                     if field.annotation is int and name != "port")

    @model_validator(mode="after")
    def validate_cap_profile(self):
        identity_fields = {"loop_caps_profile_version", "loop_caps_profile_source"}
        if self.environment.strip().lower() in {"production", "prod"}:
            missing = (set(self.resource_cap_fields()) | identity_fields) - self.model_fields_set
            if missing:
                raise ValueError("Production requires explicit cap settings: " + ", ".join(sorted(missing)))
            if (not self.loop_caps_profile_version.strip() or not self.loop_caps_profile_source.strip()
                or self.loop_caps_profile_version == "development-unpinned"
                or self.loop_caps_profile_source == "development defaults"):
                raise ValueError("Production requires an explicit versioned loop cap profile")
        if (
            self.loop_max_generated_versions > self.loop_max_versions
            or self.loop_max_total_calls > self.reading_paper_run_budget_max_calls
            or self.loop_max_total_tokens > self.reading_paper_run_budget_max_tokens
            or self.loop_max_wall_time_seconds > self.reading_paper_run_budget_max_wall_time_seconds
            or self.benchmark_child_run_max_calls > self.loop_max_total_calls
            or self.benchmark_child_run_max_tokens > self.loop_max_total_tokens
            or self.benchmark_child_run_max_wall_time_seconds > self.loop_max_wall_time_seconds
            or max(self.loop_generate_token_reservation, self.loop_evaluate_token_reservation, self.loop_repair_token_reservation, self.passage_generate_token_reservation, self.passage_generate_max_tokens) > self.loop_max_total_tokens
            or self.loop_operation_wall_reservation_seconds > self.loop_max_wall_time_seconds
        ):
            raise ValueError("Configured cap hierarchy is inconsistent")
        legacy_artifacts = (
            (self.legacy_passage_token_cap, self.legacy_passage_call_cap, self.legacy_passage_wall_time_cap_seconds),
            (self.legacy_questions_token_cap, self.legacy_questions_call_cap, self.legacy_questions_wall_time_cap_seconds),
            (self.legacy_solver_token_cap, self.legacy_solver_call_cap, self.legacy_solver_wall_time_cap_seconds),
            (self.legacy_review_token_cap, self.legacy_review_call_cap, self.legacy_review_wall_time_cap_seconds),
        )
        legacy_generation_artifacts = (
            (self.legacy_passage_token_cap, self.legacy_passage_call_cap, self.legacy_passage_wall_time_cap_seconds),
            (self.legacy_questions_token_cap, self.legacy_questions_call_cap, self.legacy_questions_wall_time_cap_seconds),
        )
        benchmark_artifacts = (
            (self.benchmark_passage_token_cap, self.benchmark_passage_call_cap, self.benchmark_passage_wall_time_cap_seconds),
            (self.benchmark_questions_token_cap, self.benchmark_questions_call_cap, self.benchmark_questions_wall_time_cap_seconds),
            (self.benchmark_solver_token_cap, self.benchmark_solver_call_cap, self.benchmark_solver_wall_time_cap_seconds),
            (self.benchmark_review_token_cap, self.benchmark_review_call_cap, self.benchmark_review_wall_time_cap_seconds),
        )
        benchmark_generation_artifacts = (
            (self.benchmark_passage_token_cap, self.benchmark_passage_call_cap, self.benchmark_passage_wall_time_cap_seconds),
            (self.benchmark_questions_token_cap, self.benchmark_questions_call_cap, self.benchmark_questions_wall_time_cap_seconds),
        )
        if (
            3 * self.legacy_section_token_cap > self.reading_paper_run_budget_max_tokens
            or 3 * self.legacy_section_call_cap > self.reading_paper_run_budget_max_calls
            or 3 * self.legacy_section_wall_time_cap_seconds > self.reading_paper_run_budget_max_wall_time_seconds
            or sum(item[0] for item in legacy_artifacts) > self.legacy_section_token_cap
            or sum(item[1] for item in legacy_artifacts) > self.legacy_section_call_cap
            or sum(item[2] for item in legacy_generation_artifacts) > self.legacy_section_wall_time_cap_seconds
            or 3 * self.benchmark_section_token_cap > self.benchmark_child_run_max_tokens
            or 3 * self.benchmark_section_call_cap > self.benchmark_child_run_max_calls
            or 3 * self.benchmark_section_wall_time_cap_seconds > self.benchmark_child_run_max_wall_time_seconds
            or sum(item[0] for item in benchmark_artifacts) > self.benchmark_section_token_cap
            or sum(item[1] for item in benchmark_artifacts) > self.benchmark_section_call_cap
            or sum(item[2] for item in benchmark_generation_artifacts) > self.benchmark_section_wall_time_cap_seconds
        ):
            raise ValueError("Configured section/artifact allocations exceed their parent caps")
        return self

    def loop_caps_snapshot(self) -> dict:
        caps = {
            "benchmarkChildRunCallCap": self.benchmark_child_run_max_calls,
            "benchmarkChildRunTokenCap": self.benchmark_child_run_max_tokens,
            "benchmarkChildRunWallTimeCapSeconds": self.benchmark_child_run_max_wall_time_seconds,
            "benchmarkSectionCallCap": self.benchmark_section_call_cap,
            "benchmarkSectionTokenCap": self.benchmark_section_token_cap,
            "benchmarkSectionWallTimeCapSeconds": self.benchmark_section_wall_time_cap_seconds,
            "benchmarkArtifactPassageCallCap": self.benchmark_passage_call_cap,
            "benchmarkArtifactPassageTokenCap": self.benchmark_passage_token_cap,
            "benchmarkArtifactPassageWallTimeCapSeconds": self.benchmark_passage_wall_time_cap_seconds,
            "benchmarkArtifactQuestionsCallCap": self.benchmark_questions_call_cap,
            "benchmarkArtifactQuestionsTokenCap": self.benchmark_questions_token_cap,
            "benchmarkArtifactQuestionsWallTimeCapSeconds": self.benchmark_questions_wall_time_cap_seconds,
            "benchmarkArtifactSolverCallCap": self.benchmark_solver_call_cap,
            "benchmarkArtifactSolverTokenCap": self.benchmark_solver_token_cap,
            "benchmarkArtifactSolverWallTimeCapSeconds": self.benchmark_solver_wall_time_cap_seconds,
            "benchmarkArtifactReviewCallCap": self.benchmark_review_call_cap,
            "benchmarkArtifactReviewTokenCap": self.benchmark_review_token_cap,
            "benchmarkArtifactReviewWallTimeCapSeconds": self.benchmark_review_wall_time_cap_seconds,
            "legacySectionCallCap": self.legacy_section_call_cap,
            "legacySectionTokenCap": self.legacy_section_token_cap,
            "legacySectionWallTimeCapSeconds": self.legacy_section_wall_time_cap_seconds,
            "legacyArtifactPassageCallCap": self.legacy_passage_call_cap,
            "legacyArtifactPassageTokenCap": self.legacy_passage_token_cap,
            "legacyArtifactPassageWallTimeCapSeconds": self.legacy_passage_wall_time_cap_seconds,
            "legacyArtifactQuestionsCallCap": self.legacy_questions_call_cap,
            "legacyArtifactQuestionsTokenCap": self.legacy_questions_token_cap,
            "legacyArtifactQuestionsWallTimeCapSeconds": self.legacy_questions_wall_time_cap_seconds,
            "legacyArtifactSolverCallCap": self.legacy_solver_call_cap,
            "legacyArtifactSolverTokenCap": self.legacy_solver_token_cap,
            "legacyArtifactSolverWallTimeCapSeconds": self.legacy_solver_wall_time_cap_seconds,
            "legacyArtifactReviewCallCap": self.legacy_review_call_cap,
            "legacyArtifactReviewTokenCap": self.legacy_review_token_cap,
            "legacyArtifactReviewWallTimeCapSeconds": self.legacy_review_wall_time_cap_seconds,
            "candidateMaxBacktrackingSteps": self.candidate_max_backtracking_steps,
            "candidateMaxSearchDepth": self.candidate_max_search_depth,
            "candidatePoolLimitCompletion": self.candidate_pool_limit_completion,
            "candidatePoolLimitMcq": self.candidate_pool_limit_mcq,
            "candidatePoolLimitShortAnswer": self.candidate_pool_limit_short_answer,
            "candidatePoolLimitSummary": self.candidate_pool_limit_summary,
            "candidatePoolLimitTfng": self.candidate_pool_limit_tfng,
            "evaluationCacheMaxEntries": self.evaluation_cache_max_entries,
            "evaluatorDeterministicTimeoutSeconds": self.evaluator_deterministic_timeout_seconds,
            "evaluatorMaxTokensPerEvaluation": self.evaluator_max_tokens_per_evaluation,
            "evaluatorSemanticTimeoutSeconds": self.evaluator_semantic_timeout_seconds,
            "evaluatorStageTimeoutSeconds": self.evaluator_stage_timeout_seconds,
            "generateTokenReservation": self.loop_generate_token_reservation,
            "passageGenerateTokenReservation": self.passage_generate_token_reservation,
            "passageGenerateMaxTokens": self.passage_generate_max_tokens,
            "evaluateTokenReservation": self.loop_evaluate_token_reservation,
            "loopMaxConsecutiveNoProgress": self.loop_max_consecutive_no_progress,
            "loopMaxGeneratedVersions": self.loop_max_generated_versions,
            "loopMaxOscillationCycles": self.loop_max_oscillation_cycles,
            "loopMaxRepairAttemptsPerVersion": self.loop_max_repair_attempts_per_version,
            "loopMaxResponseBytes": self.loop_max_response_bytes,
            "loopMaxTotalCalls": self.loop_max_total_calls,
            "loopMaxTotalRepairs": self.loop_max_total_repairs,
            "loopMaxTotalTokens": self.loop_max_total_tokens,
            "loopMaxVersions": self.loop_max_versions,
            "loopMaxWallTimeSeconds": self.loop_max_wall_time_seconds,
            "loopOperationWallReservationSeconds": self.loop_operation_wall_reservation_seconds,
            "repairMaxTokensPerAttempt": self.repair_max_tokens_per_attempt,
            "repairTimeoutSeconds": self.repair_timeout_seconds,
            "repairTokenReservation": self.loop_repair_token_reservation,
            "standaloneRunBudgetCapCalls": self.reading_paper_run_budget_max_calls,
            "standaloneRunBudgetCapTokens": self.reading_paper_run_budget_max_tokens,
            "standaloneRunBudgetCapWallTimeSeconds": self.reading_paper_run_budget_max_wall_time_seconds,
        }
        return {
            "benchmarkMode": self.benchmark_caps_mode,
            "benchmarkMonetaryCapMode": self.benchmark_monetary_cap_mode,
            "caps": caps,
            "profileSource": self.loop_caps_profile_source,
            "profileVersion": self.loop_caps_profile_version,
        }

    def provider_binding_snapshot(self) -> dict:
        """Non-secret provider/runtime identity that determines what a measurement actually hit.

        The loop caps alone do not identify the run: a different endpoint host or model produces
        different numbers under an identical caps profile. Secret material (API keys) is deliberately
        excluded -- only the fields that select where and what is called belong in a hashable binding.
        """
        return {
            "llmProviderOrder": self.llm_provider_order,
            "minimaxBaseUrl": self.minimax_base_url,
            "minimaxModel": self.minimax_model,
            "groqBaseUrl": self.groq_base_url,
            "groqModel": self.groq_model,
        }

    def create_unlimited_benchmark_snapshot(self, version: str = "minimax-benchmark-unlimited-v1", source: str = "automated-minimax-benchmark") -> dict:
        snapshot = self.loop_caps_snapshot()
        snapshot["benchmarkMode"] = "UNLIMITED"
        snapshot["benchmarkMonetaryCapMode"] = "UNLIMITED"
        snapshot["profileVersion"] = version
        snapshot["profileSource"] = source
        snapshot["providerBinding"] = self.provider_binding_snapshot()
        caps = snapshot.setdefault("caps", {})
        caps["evaluatorSemanticTimeoutSeconds"] = 300
        caps["evaluatorStageTimeoutSeconds"] = 300
        caps["repairTimeoutSeconds"] = 120
        caps["loopOperationWallReservationSeconds"] = 300
        caps["benchmarkArtifactSolverWallTimeCapSeconds"] = 180
        caps["benchmarkArtifactReviewWallTimeCapSeconds"] = 180
        return snapshot

    @property
    def loop_caps_profile_json(self) -> str:
        return cap_snapshot_json(self.loop_caps_snapshot())

    @property
    def loop_caps_profile_sha256(self) -> str:
        return cap_snapshot_sha256(self.loop_caps_snapshot())


settings = Settings()
